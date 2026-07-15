/*
  Warnings:

  - Renamed the column `content` on the `Comment` table to `message`.
  - Renamed the column `userId` on the `Comment` table to `authorId`.

  Note: every statement below is written to be safely re-runnable.
  A prior partial attempt at this migration ran with autocommit
  (Postgres does not allow ALTER TYPE ... ADD VALUE inside the same
  transaction as other DDL in some execution paths), so earlier
  statements may already be committed even though the migration
  as a whole reported failure.
*/

-- CreateEnum (idempotent)
DO $$ BEGIN
    CREATE TYPE "BacklogStatus" AS ENUM ('UNGROOMED', 'READY', 'BLOCKED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "Recurrence" AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE "SprintStatus" AS ENUM ('PLANNED', 'ACTIVE', 'COMPLETED', 'CANCELLED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- AlterEnum (idempotent via IF NOT EXISTS, supported since PG 9.6)
ALTER TYPE "NotificationType" ADD VALUE IF NOT EXISTS 'SPRINT_STARTED';
ALTER TYPE "NotificationType" ADD VALUE IF NOT EXISTS 'SPRINT_COMPLETED';
ALTER TYPE "NotificationType" ADD VALUE IF NOT EXISTS 'TASK_MOVED_TO_SPRINT';
ALTER TYPE "NotificationType" ADD VALUE IF NOT EXISTS 'SPRINT_ENDING';

-- DropForeignKey (guarded: production had no such FK on this column)
ALTER TABLE "Comment" DROP CONSTRAINT IF EXISTS "Comment_userId_fkey";

-- DropIndex (guarded: production had no such index on this column)
DROP INDEX IF EXISTS "Comment_userId_idx";

-- RenameColumn: preserve existing comment data instead of drop+recreate.
-- Guarded so it's a no-op if already renamed by a prior partial run.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Comment' AND column_name = 'userId')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Comment' AND column_name = 'authorId') THEN
    ALTER TABLE "Comment" RENAME COLUMN "userId" TO "authorId";
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Comment' AND column_name = 'content')
     AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Comment' AND column_name = 'message') THEN
    ALTER TABLE "Comment" RENAME COLUMN "content" TO "message";
  END IF;
END $$;

-- AlterTable: add the genuinely new columns (idempotent)
ALTER TABLE "Comment" ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMP(3);
ALTER TABLE "Comment" ADD COLUMN IF NOT EXISTS "editedAt" TIMESTAMP(3);
ALTER TABLE "Comment" ADD COLUMN IF NOT EXISTS "mentions" TEXT[] DEFAULT ARRAY[]::TEXT[];
ALTER TABLE "Comment" ADD COLUMN IF NOT EXISTS "parentCommentId" TEXT;

-- Safety net: in case any legacy rows already had a NULL userId/content
-- before this migration ran, point them at a placeholder system user
-- rather than failing the deploy.
INSERT INTO "User" (id, name, email, password, role, "createdAt", "updatedAt")
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'Deleted User',
  'deleted-user@system.internal',
  '',
  'USER',
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

UPDATE "Comment" SET "authorId" = '00000000-0000-0000-0000-000000000000' WHERE "authorId" IS NULL;
UPDATE "Comment" SET "message" = '' WHERE "message" IS NULL;

-- Now safe to enforce NOT NULL (no-op if already NOT NULL)
ALTER TABLE "Comment" ALTER COLUMN "authorId" SET NOT NULL;
ALTER TABLE "Comment" ALTER COLUMN "message" SET NOT NULL;

-- AlterTable (idempotent)
ALTER TABLE "Project" ADD COLUMN IF NOT EXISTS "sprintId" TEXT;

-- AlterTable (idempotent)
ALTER TABLE "Task" ADD COLUMN IF NOT EXISTS "backlogStatus" "BacklogStatus" DEFAULT 'UNGROOMED';
ALTER TABLE "Task" ADD COLUMN IF NOT EXISTS "isRecurring" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "Task" ADD COLUMN IF NOT EXISTS "parentId" TEXT;
ALTER TABLE "Task" ADD COLUMN IF NOT EXISTS "recurrence" "Recurrence";
ALTER TABLE "Task" ADD COLUMN IF NOT EXISTS "sprintId" TEXT;
ALTER TABLE "Task" ADD COLUMN IF NOT EXISTS "storyPoints" INTEGER;

-- CreateTable (idempotent)
CREATE TABLE IF NOT EXISTS "Sprint" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "goal" TEXT,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "status" "SprintStatus" NOT NULL DEFAULT 'PLANNED',
    "teamId" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Sprint_pkey" PRIMARY KEY ("id")
);

-- CreateIndex (idempotent)
CREATE INDEX IF NOT EXISTS "Sprint_teamId_idx" ON "Sprint"("teamId");
CREATE INDEX IF NOT EXISTS "Sprint_workspaceId_idx" ON "Sprint"("workspaceId");
CREATE INDEX IF NOT EXISTS "Sprint_createdById_idx" ON "Sprint"("createdById");
CREATE INDEX IF NOT EXISTS "Sprint_status_idx" ON "Sprint"("status");
CREATE INDEX IF NOT EXISTS "Comment_authorId_idx" ON "Comment"("authorId");
CREATE INDEX IF NOT EXISTS "Project_sprintId_idx" ON "Project"("sprintId");
CREATE INDEX IF NOT EXISTS "Task_sprintId_idx" ON "Task"("sprintId");
CREATE INDEX IF NOT EXISTS "Task_parentId_idx" ON "Task"("parentId");

-- AddForeignKey (idempotent, guarded against duplicate constraint names)
DO $$ BEGIN
    ALTER TABLE "Task" ADD CONSTRAINT "Task_sprintId_fkey" FOREIGN KEY ("sprintId") REFERENCES "Sprint"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Task" ADD CONSTRAINT "Task_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Task"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Project" ADD CONSTRAINT "Project_sprintId_fkey" FOREIGN KEY ("sprintId") REFERENCES "Sprint"("id") ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Comment" ADD CONSTRAINT "Comment_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Comment" ADD CONSTRAINT "Comment_parentCommentId_fkey" FOREIGN KEY ("parentCommentId") REFERENCES "Comment"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;