import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { createTaskSchema } from "../utils/task.schema.js";
import { io } from "../server.js";
import { failure, success } from "../utils/response.js";
import { ca, tr } from "zod/locales";

export const createTask = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) {
      return failure(res, "Unauthorized", 401);
    }

    const data = createTaskSchema.parse(req.body);

    const task = await prisma.task.create({
      data: {
        title: data.title,
        description: data.description,
        projectId: data.projectId,
        createdById: req.user.userId,
      },
    });

    await prisma.activityLog.create({
      data: {
        action: `Created task ${task.title}`,
        userId: req.user.userId,
        projectId: task.projectId,
      },
    });
    io.emit("task:created", task);

    return success(res, "Task created successfully", task, 201);
  } catch (err) {
    console.error("TASK CREATE ERROR:", err);
    return failure(res, "Server Error", 500);
  }
};

export const getTasks = async (req: AuthRequest, res: Response) => {
  try {
    const { projectId } = req.params;
    const { page = "1", q = "" } = req.query;

    const pageNumber = Number(page);
    const pageSize = 10;

    const tasks = await prisma.task.findMany({
      where: {
        projectId,
        title: {
          contains: q as string,
          mode: "insensitive",
        },
      },
      skip: (pageNumber - 1) * pageSize,
      take: pageSize,
      orderBy: {
        createdAt: "desc",
      },
    });

    const total = await prisma.task.count({
      where: {
        projectId,
        title: {
          contains: q as string,
          mode: "insensitive",
        },
      },
    });

    return success(res, "Tasks fetched successfully", {
      items: tasks,
      meta: {
        page: pageNumber,
        pageSize,
        total,
        totalPages: Math.ceil(total / pageSize),
      },
    });
  } catch (error) {
    console.error("Error fetching tasks:", error);
    return failure(res, "Internal server error", 500);
  }
};

export const updateTask = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { title, description, status } = req.body;

    const task = await prisma.task.findUnique({
      where: { id },
    });

    if (!task) {
      return failure(res, "Task not found", 404);
    }

    const updatedTask = await prisma.task.update({
      where: { id },
      data: {
        title,
        description,
        status,
      },
    });

    // activity log
    await prisma.activityLog.create({
      data: {
        action: `Updated task ${updatedTask.title}`,
        userId: req.user!.userId,
        projectId: updatedTask.projectId,
      },
    });

    // realtime event
    io.emit("task:updated", updatedTask);

    return success(res, "Task updated successfully", updatedTask);
  } catch (error) {
    console.error("Error updating task:", error);
    return failure(res, "Internal server error", 500);
  }
};

export const deleteTask = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;

    const task = await prisma.task.findUnique({
      where: { id },
    });

    if (!task) {
      return failure(res, "Task not found", 404);
    }

    await prisma.task.delete({
      where: { id },
    });

    await prisma.activityLog.create({
      data: {
        action: `Deleted task ${task.title}`,
        userId: req.user!.userId,
        projectId: task.projectId,
      },
    });

    io.emit("task:deleted", { id });

    return success(res, "Task deleted successfully", null, 200);
  } catch (error) {
    console.error("Error deleting task:", error);
    return failure(res, "Internal server error", 500);
  }
};
