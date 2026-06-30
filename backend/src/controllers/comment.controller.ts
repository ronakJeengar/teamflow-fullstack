import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse, paginatedResponse } from "../utils/response.js";
import { createCommentSchema } from "../utils/validation.js";
import { io } from "../server.js";
import { createNotification } from "./notification.controller.js";

// GET /tasks/:taskId/comments — list comments for a task (paginated)
export const getComments = async (req: AuthRequest, res: Response) => {
  try {
    const { taskId } = req.params;
    const userId = req.user!.userId;

    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = (page - 1) * limit;

    const task = await prisma.task.findUnique({
      where: { id: taskId },
      select: {
        createdById: true,
        assignedToId: true,
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

    // Verify user is creator, assignee, or team member using compound unique index
    const isMember = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId: task.project.teamId,
          userId,
        },
      },
    });

    const isCreator = task.createdById === userId;
    const isAssignee = task.assignedToId === userId;

    if (!isMember && !isCreator && !isAssignee) {
      return errorResponse(res, "Access denied. Not authorized.", 403);
    }

    const whereClause = {
      taskId,
      deletedAt: null,
    };

    const comments = await prisma.comment.findMany({
      where: whereClause,
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatar: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
    });

    const total = await prisma.comment.count({
      where: whereClause,
    });

    // To preserve mobile backward compatibility, map `author` to `user` and `message` to `content` in output
    const mappedComments = comments.map((comment) => ({
      ...comment,
      content: comment.message, // Map to `content` for mobile
      user: comment.author,     // Map to `user` for mobile
      userId: comment.authorId, // Map to `userId` for mobile
    }));

    return paginatedResponse(res, mappedComments, total, page, limit);
  } catch (error) {
    console.error("Error fetching comments:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// POST /tasks/:taskId/comments — create comment { message, parentCommentId }
export const createComment = async (req: AuthRequest, res: Response) => {
  try {
    const { taskId } = req.params;
    const userId = req.user!.userId;

    const validation = createCommentSchema.safeParse(req.body);
    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { message, parentCommentId } = validation.data;

    const task = await prisma.task.findUnique({
      where: { id: taskId },
      select: {
        title: true,
        projectId: true,
        createdById: true,
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

    // Verify user is creator, assignee, or team member using compound unique index
    const isMember = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId: task.project.teamId,
          userId,
        },
      },
    });

    const isCreator = task.createdById === userId;
    const isAssignee = task.assignedToId === userId;

    if (!isMember && !isCreator && !isAssignee) {
      return errorResponse(res, "Access denied. Not authorized.", 403);
    }

    // Parse mentions (e.g. @john or @john@example.com)
    const mentionRegex = /@([a-zA-Z0-9._-]+)/g;
    const matches = [...message.matchAll(mentionRegex)].map((m) => m[1]);
    
    let mentions: string[] = [];
    if (matches.length > 0) {
      const users = await prisma.user.findMany({
        where: {
          OR: [
            { name: { in: matches, mode: "insensitive" } },
            { email: { in: matches, mode: "insensitive" } },
          ],
        },
        select: { id: true },
      });
      mentions = users.map((u) => u.id);
    }

    const comment = await prisma.comment.create({
      data: {
        message,
        taskId,
        authorId: userId,
        parentCommentId: parentCommentId || undefined,
        mentions,
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
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

    // Map to compat output
    const compatComment = {
      ...comment,
      content: comment.message,
      user: comment.author,
      userId: comment.authorId, // Map to `userId` for mobile
    };

    // Notify assignee, task creator, and mentioned users
    // Build set of users to notify, excluding the commenter
    const notifySet = new Set<string>();
    if (task.assignedToId && task.assignedToId !== userId) {
      notifySet.add(task.assignedToId);
    }
    if (task.createdById && task.createdById !== userId) {
      notifySet.add(task.createdById);
    }

    // Create a body preview
    const bodyPreview = message.length > 40 ? `${message.substring(0, 40)}...` : message;

    // Send notifications to assignees/creator
    for (const recipientId of notifySet) {
      // If the recipient is also mentioned, we will send the MENTION type instead
      if (!mentions.includes(recipientId)) {
        await createNotification({
          userId: recipientId,
          senderId: userId,
          type: "TASK_COMMENTED",
          title: "New Comment on Task",
          body: `${compatComment.user.name} commented on "${task.title}": "${bodyPreview}"`,
          taskId,
          projectId: task.projectId,
        });
      }
    }

    // Send notifications to mentioned users
    for (const mentionId of mentions) {
      if (mentionId !== userId) {
        await createNotification({
          userId: mentionId,
          senderId: userId,
          type: "MENTION",
          title: "You were mentioned in a comment",
          body: `${compatComment.user.name} mentioned you in "${task.title}": "${bodyPreview}"`,
          taskId,
          projectId: task.projectId,
        });
      }
    }

    // Emit socket event
    io.to(`task:${taskId}`).emit("task:comment_added", compatComment);

    return successResponse(res, compatComment, "Comment created successfully", 201);
  } catch (error) {
    console.error("Error creating comment:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// PATCH /comments/:commentId — edit own comment only
export const updateComment = async (req: AuthRequest, res: Response) => {
  try {
    const { commentId } = req.params;
    const userId = req.user!.userId;

    const validation = createCommentSchema.safeParse(req.body);
    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { message } = validation.data;

    const comment = await prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment || comment.deletedAt !== null) {
      return errorResponse(res, "Comment not found", 404);
    }

    if (comment.authorId !== userId) {
      return errorResponse(res, "Access denied. You can only edit your own comments.", 403);
    }

    const updatedComment = await prisma.comment.update({
      where: { id: commentId },
      data: {
        message,
        editedAt: new Date(),
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatar: true,
          },
        },
      },
    });

    const compatComment = {
      ...updatedComment,
      content: updatedComment.message,
      user: updatedComment.author,
      userId: updatedComment.authorId, // Map to `userId` for mobile
    };

    // Emit socket event
    io.to(`task:${comment.taskId}`).emit("task:comment_updated", compatComment);

    return successResponse(res, compatComment, "Comment updated successfully");
  } catch (error) {
    console.error("Error updating comment:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// DELETE /comments/:commentId — delete own comment only (soft delete)
export const deleteComment = async (req: AuthRequest, res: Response) => {
  try {
    const { commentId } = req.params;
    const userId = req.user!.userId;

    const comment = await prisma.comment.findUnique({
      where: { id: commentId },
    });

    if (!comment || comment.deletedAt !== null) {
      return errorResponse(res, "Comment not found", 404);
    }

    if (comment.authorId !== userId) {
      return errorResponse(res, "Access denied. You can only delete your own comments.", 403);
    }

    // Perform soft delete
    const deletedComment = await prisma.comment.update({
      where: { id: commentId },
      data: {
        deletedAt: new Date(),
      },
      include: {
        author: {
          select: {
            id: true,
            name: true,
            email: true,
            avatar: true,
          },
        },
      },
    });

    const compatComment = {
      ...deletedComment,
      content: deletedComment.message,
      user: deletedComment.author,
      userId: deletedComment.authorId, // Map to `userId` for mobile
    };

    // Emit socket event
    io.to(`task:${comment.taskId}`).emit("task:comment_deleted", { commentId });

    return successResponse(res, null, "Comment deleted successfully");
  } catch (error) {
    console.error("Error deleting comment:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
