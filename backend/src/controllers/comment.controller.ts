import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { createCommentSchema } from "../utils/validation.js";
import { io } from "../server.js";
import { createNotification } from "./notification.controller.js";

// GET /tasks/:taskId/comments — list comments for a task
export const getComments = async (req: AuthRequest, res: Response) => {
  try {
    const { taskId } = req.params;
    const userId = req.user!.userId;

    const task = await prisma.task.findUnique({
      where: { id: taskId },
      select: {
        projectId: true,
        project: {
          select: {
            teamId: true,
          },
        },
      },
    });

    if (!task) {
      return errorResponse(res, "Task not found", 404);
    }

    // Verify user is in the team using compound unique index
    const isMember = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId: task.project.teamId,
          userId,
        },
      },
    });

    if (!isMember) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    const comments = await prisma.comment.findMany({
      where: { taskId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
      orderBy: { createdAt: "asc" },
    });

    return successResponse(res, comments);
  } catch (error) {
    console.error("Error fetching comments:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// POST /tasks/:taskId/comments — create comment { content }
export const createComment = async (req: AuthRequest, res: Response) => {
  try {
    const { taskId } = req.params;
    const userId = req.user!.userId;

    const validation = createCommentSchema.safeParse(req.body);
    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { content } = validation.data;

    const task = await prisma.task.findUnique({
      where: { id: taskId },
      select: {
        title: true,
        projectId: true,
        assignedToId: true,
        project: {
          select: {
            teamId: true,
          },
        },
      },
    });

    if (!task) {
      return errorResponse(res, "Task not found", 404);
    }

    // Verify user is in the team using compound unique index
    const isMember = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId: task.project.teamId,
          userId,
        },
      },
    });

    if (!isMember) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    const comment = await prisma.comment.create({
      data: {
        content,
        taskId,
        userId,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    // Log Activity
    await prisma.activityLog.create({
      data: {
        action: `commented on task "${task.title}"`,
        userId,
        taskId,
        projectId: task.projectId,
      },
    });

    // Create notification for task assignee if set and is not the commenter
    if (task.assignedToId && task.assignedToId !== userId) {
      await createNotification({
        userId: task.assignedToId,
        senderId: userId,
        type: "TASK_COMMENTED",
        title: "New Comment on Task",
        body: `${comment.user.name} commented on "${task.title}": "${content.substring(0, 40)}${content.length > 40 ? "..." : ""}"`,
        taskId,
        projectId: task.projectId,
      });
    }

    // Emit socket event
    io.to(`task:${taskId}`).emit("task:comment_added", { comment, user: comment.user });

    return successResponse(res, comment, "Comment created successfully", 201);
  } catch (error) {
    console.error("Error creating comment:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// PATCH /tasks/:taskId/comments/:commentId — edit own comment only
export const updateComment = async (req: AuthRequest, res: Response) => {
  try {
    const { taskId, commentId } = req.params;
    const userId = req.user!.userId;

    const validation = createCommentSchema.safeParse(req.body);
    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { content } = validation.data;

    const comment = await prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment || comment.taskId !== taskId) {
      return errorResponse(res, "Comment not found", 404);
    }

    if (comment.userId !== userId) {
      return errorResponse(res, "Access denied. You can only edit your own comments.", 403);
    }

    const updatedComment = await prisma.comment.update({
      where: { id: commentId },
      data: { content },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    return successResponse(res, updatedComment, "Comment updated successfully");
  } catch (error) {
    console.error("Error updating comment:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// DELETE /tasks/:taskId/comments/:commentId — delete own comment only
export const deleteComment = async (req: AuthRequest, res: Response) => {
  try {
    const { taskId, commentId } = req.params;
    const userId = req.user!.userId;

    const comment = await prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment || comment.taskId !== taskId) {
      return errorResponse(res, "Comment not found", 404);
    }

    if (comment.userId !== userId) {
      return errorResponse(res, "Access denied. You can only delete your own comments.", 403);
    }

    await prisma.comment.delete({
      where: { id: commentId },
    });

    return successResponse(res, null, "Comment deleted successfully");
  } catch (error) {
    console.error("Error deleting comment:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
