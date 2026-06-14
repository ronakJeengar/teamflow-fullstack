import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { createTaskSchema } from "../utils/task.schema.js";
import { io } from "../server.js";
import { failure, success } from "../utils/response.js";

export const createTask = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) return failure(res, "Unauthorized", 401);

    const data = createTaskSchema.parse(req.body);

    // Verify user is a team member via the project
    const project = await prisma.project.findUnique({
      where: { id: data.projectId },
    });

    if (!project) return failure(res, "Project not found", 404);

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId: req.user.userId },
    });

    if (!member) return failure(res, "Not a team member", 403);

    // VIEWER cannot create tasks
    if (member.role === "VIEWER") {
      return failure(res, "Viewers cannot create tasks", 403);
    }

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
        title: { contains: q as string, mode: "insensitive" },
      },
      skip: (pageNumber - 1) * pageSize,
      take: pageSize,
      orderBy: { createdAt: "desc" },
    });

    const total = await prisma.task.count({
      where: {
        projectId,
        title: { contains: q as string, mode: "insensitive" },
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
    const userId = req.user!.userId;

    const task = await prisma.task.findUnique({ where: { id } });
    if (!task) return failure(res, "Task not found", 404);

    const project = await prisma.project.findUnique({
      where: { id: task.projectId },
    });

    if (!project) return failure(res, "Project not found", 404);

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) return failure(res, "Not a team member", 403);

    // VIEWER cannot update tasks
    // MEMBER can only update their own tasks
    if (member.role === "VIEWER") {
      return failure(res, "Viewers cannot update tasks", 403);
    }

    if (member.role === "MEMBER" && task.createdById !== userId) {
      return failure(res, "Members can only edit their own tasks", 403);
    }

    const updatedTask = await prisma.task.update({
      where: { id },
      data: { title, description, status },
    });

    await prisma.activityLog.create({
      data: {
        action: `Updated task ${updatedTask.title}`,
        userId,
        projectId: updatedTask.projectId,
      },
    });

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
    const userId = req.user!.userId;

    const task = await prisma.task.findUnique({ where: { id } });
    if (!task) return failure(res, "Task not found", 404);

    const project = await prisma.project.findUnique({
      where: { id: task.projectId },
    });

    if (!project) return failure(res, "Project not found", 404);

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) return failure(res, "Not a team member", 403);

    // VIEWER cannot delete tasks
    // MEMBER can only delete their own tasks
    if (member.role === "VIEWER") {
      return failure(res, "Viewers cannot delete tasks", 403);
    }

    if (member.role === "MEMBER" && task.createdById !== userId) {
      return failure(res, "Members can only delete their own tasks", 403);
    }

    await prisma.task.delete({ where: { id } });

    await prisma.activityLog.create({
      data: {
        action: `Deleted task ${task.title}`,
        userId,
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
