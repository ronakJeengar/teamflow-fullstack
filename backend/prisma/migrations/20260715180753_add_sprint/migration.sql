/*
  Warnings:

  - Renamed the column `content` on the `Comment` table to `message`.
  - Renamed the column `userId` on the `Comment` table to `authorId`.

*/
-- CreateEnum
CREATE TYPE "BacklogStatus" AS ENUM ('UNGROOMED', 'READY', 'BLOCKED');

-- CreateEnum
CREATE TYPE "Recurrence" AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY');

-- CreateEnum
CREATE TYPE "SprintStatus" AS ENUM ('PLANNED', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'SPRINT_STARTED';
ALTER TYPE "NotificationType" ADD VALUE 'SPRINT_COMPLETED';
ALTER TYPE "NotificationType" ADD VALUE 'TASK_MOVED_TO_SPRINT';
ALTER TYPE "NotificationType" ADD VALUE 'SPRINT_ENDING';

-- DropForeignKey
ALTER TABLE "Comment" DROP CONSTRAINT "Comment_userId_fkey";

-- DropIndex
DROP INDEX "Comment_userId_idx";

-- RenameColumn: preserve existing comment data instead of drop+recreate
ALTER TABLE "Comment" RENAME COLUMN "userId" TO "authorId";
ALTER TABLE "Comment" RENAME COLUMN "content" TO "message";

-- AlterTable: add the genuinely new columns
ALTER TABLE "Comment"
  ADD COLUMN     "deletedAt" TIMESTAMP(3),
  ADD COLUMN     "editedAt" TIMESTAMP(3),
  ADD COLUMN     "mentions" TEXT[] DEFAULT ARRAY[]::TEXT[],
  ADD COLUMN     "parentCommentId" TEXT;

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

-- Now safe to enforce NOT NULL
ALTER TABLE "Comment" ALTER COLUMN "authorId" SET NOT NULL;
ALTER TABLE "Comment" ALTER COLUMN "message" SET NOT NULL;

-- AlterTable
ALTER TABLE "Project" ADD COLUMN     "sprintId" TEXT;

-- AlterTable
ALTER TABLE "Task" ADD COLUMN     "backlogStatus" "BacklogStatus" DEFAULT 'UNGROOMED',
ADD COLUMN     "isRecurring" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "parentId" TEXT,
ADD COLUMN     "recurrence" "Recurrence",
ADD COLUMN     "sprintId" TEXT,
ADD COLUMN     "storyPoints" INTEGER;

-- CreateTable
CREATE TABLE "Sprint" (
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

-- CreateIndex
CREATE INDEX "Sprint_teamId_idx" ON "Sprint"("teamId");

-- CreateIndex
CREATE INDEX "Sprint_workspaceId_idx" ON "Sprint"("workspaceId");

-- CreateIndex
CREATE INDEX "Sprint_createdById_idx" ON "Sprint"("createdById");

-- CreateIndex
CREATE INDEX "Sprint_status_idx" ON "Sprint"("status");

-- CreateIndex
CREATE INDEX "Comment_authorId_idx" ON "Comment"("authorId");

-- CreateIndex
CREATE INDEX "Project_sprintId_idx" ON "Project"("sprintId");

-- CreateIndex
CREATE INDEX "Task_sprintId_idx" ON "Task"("sprintId");

-- CreateIndex
CREATE INDEX "Task_parentId_idx" ON "Task"("parentId");

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_sprintId_fkey" FOREIGN KEY ("sprintId") REFERENCES "Sprint"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Task" ADD CONSTRAINT "Task_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "Task"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Project" ADD CONSTRAINT "Project_sprintId_fkey" FOREIGN KEY ("sprintId") REFERENCES "Sprint"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_parentCommentId_fkey" FOREIGN KEY ("parentCommentId") REFERENCES "Comment"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "Team"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "Workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sprint" ADD CONSTRAINT "Sprint_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;