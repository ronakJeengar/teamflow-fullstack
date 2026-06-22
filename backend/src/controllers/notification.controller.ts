import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { NotificationType } from "@prisma/client";
import { io } from "../server.js";

// GET /notifications — paginated, grouped by date for current user
export const getNotifications = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = (page - 1) * limit;

    const notifications = await prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
      include: {
        sender: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const yesterdayStart = new Date(todayStart);
    yesterdayStart.setDate(todayStart.getDate() - 1);

    const today: typeof notifications = [];
    const yesterday: typeof notifications = [];
    const older: typeof notifications = [];

    for (const notification of notifications) {
      const createdTime = new Date(notification.createdAt);
      if (createdTime >= todayStart) {
        today.push(notification);
      } else if (createdTime >= yesterdayStart) {
        yesterday.push(notification);
      } else {
        older.push(notification);
      }
    }

    return successResponse(res, { today, yesterday, older });
  } catch (error) {
    console.error("Error fetching notifications:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /notifications/unread-count — returns { count: number }
export const getUnreadCount = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const count = await prisma.notification.count({
      where: { userId, isRead: false },
    });
    return successResponse(res, { count });
  } catch (error) {
    console.error("Error fetching unread count:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// PATCH /notifications/:id/read — mark single as read
export const markAsRead = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const notification = await prisma.notification.findUnique({
      where: { id },
    });

    if (!notification || notification.userId !== userId) {
      return errorResponse(res, "Notification not found", 404);
    }

    const updated = await prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });

    return successResponse(res, updated, "Notification marked as read");
  } catch (error) {
    console.error("Error marking notification as read:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// PATCH /notifications/read-all — mark all as read for current user
export const markAllAsRead = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;

    await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });

    return successResponse(res, null, "All notifications marked as read");
  } catch (error) {
    console.error("Error marking all notifications as read:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// DELETE /notifications/:id — delete notification
export const deleteNotification = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const notification = await prisma.notification.findUnique({
      where: { id },
    });

    if (!notification || notification.userId !== userId) {
      return errorResponse(res, "Notification not found", 404);
    }

    await prisma.notification.delete({
      where: { id },
    });

    return successResponse(res, null, "Notification deleted successfully");
  } catch (error) {
    console.error("Error deleting notification:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// Helper: createNotification(data) — internal function used by other controllers
export const createNotification = async (data: {
  userId: string;
  senderId?: string | null;
  type: NotificationType;
  title: string;
  body: string;
  taskId?: string | null;
  projectId?: string | null;
  teamId?: string | null;
}) => {
  const notification = await prisma.notification.create({
    data: {
      userId: data.userId,
      senderId: data.senderId || undefined,
      type: data.type,
      title: data.title,
      body: data.body,
      taskId: data.taskId || undefined,
      projectId: data.projectId || undefined,
      teamId: data.teamId || undefined,
    },
    include: {
      sender: {
        select: {
          id: true,
          name: true,
          avatar: true,
        },
      },
    },
  });

  io.to(`user:${data.userId}`).emit("notification:new", notification);
  return notification;
};
