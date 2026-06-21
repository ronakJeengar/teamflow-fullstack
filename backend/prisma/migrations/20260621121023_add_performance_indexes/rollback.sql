-- Rollback Migration: Remove performance indexes
DROP INDEX IF EXISTS "Task_createdById_idx";
DROP INDEX IF EXISTS "Team_workspaceId_idx";
DROP INDEX IF EXISTS "WorkspaceMember_userId_idx";
