/*
  Warnings:

  - You are about to drop the column `invitedBy` on the `TeamInvitation` table. All the data in the column will be lost.
  - Added the required column `invitedById` to the `TeamInvitation` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `TeamInvitation` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "TeamInvitation_token_idx";

-- AlterTable
ALTER TABLE "TeamInvitation" DROP COLUMN "invitedBy",
ADD COLUMN     "invitedById" TEXT NOT NULL,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL;

-- CreateIndex
CREATE INDEX "TeamInvitation_status_idx" ON "TeamInvitation"("status");

-- AddForeignKey
ALTER TABLE "TeamInvitation" ADD CONSTRAINT "TeamInvitation_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
