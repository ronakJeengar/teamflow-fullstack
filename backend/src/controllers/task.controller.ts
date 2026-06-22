import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { createTaskSchema, updateTaskSchema } from "../utils/validation.js";
import { io } from "../server.js";
import { successResponse, errorResponse, paginatedResponse } from "../utils/response.js";
import { createNotification } from "./notification.controller.js";

// GET /tasks/my — tasks assigned to current user
export const getMyTasks = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const { status, tab } = req.query;

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayEnd = new Date(todayStart);
    todayEnd.setHours(23, 59, 59, 999);

    const whereClause: any = {
      assignedToId: userId,
    };

    if (status) {
      whereClause.status = status;
    }

    if (tab === "due_today") {
      whereClause.dueDate = {
        gte: todayStart,
        lte: todayEnd,
      };
    } else if (tab === "upcoming") {
      whereClause.dueDate = {
        gt: todayEnd,
      };
      whereClause.status = {
        not: "DONE",
      };
    } else if (tab === "completed") {
      whereClause.status = "DONE";
    }

    const tasks = await prisma.task.findMany({
      where: whereClause,
      include: {
        project: {
          select: {
            id: true,
            name: true,
            team: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
        assignedTo: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
      orderBy: { dueDate: "asc" },
    });

    return successResponse(res, tasks, "My tasks fetched successfully");
  } catch (error) {
    console.error("Error fetching my tasks:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /tasks/:id — single task with full detail OR fallback to project's tasks
export const getTaskById = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    // 1. Try to fetch as single task
    const task = await prisma.task.findUnique({
      where: { id },
      include: {
        assignedTo: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        createdBy: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        project: {
          select: {
            id: true,
            name: true,
            teamId: true,
          },
        },
        _count: {
          select: {
            comments: true,
          },
        },
        activities: {
          orderBy: { createdAt: "desc" },
          take: 3,
          include: {
            user: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
          },
        },
      },
    });

    if (task) {
      // Verify user is in the team
      const isMember = await prisma.teamMember.findFirst({
        where: { teamId: task.project.teamId, userId },
      });

      if (!isMember) {
        return errorResponse(res, "Access denied. Not a team member.", 403);
      }

      return successResponse(res, task, "Task fetched successfully");
    }

    // 2. Fallback: try to fetch as project tasks
    const project = await prisma.project.findUnique({
      where: { id },
    });

    if (project) {
      const isMember = await prisma.teamMember.findFirst({
        where: { teamId: project.teamId, userId },
      });

      if (!isMember) {
        return errorResponse(res, "Access denied. Not a team member.", 403);
      }

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const q = (req.query.q as string) || "";

      const tasks = await prisma.task.findMany({
        where: {
          projectId: id,
          title: { contains: q, mode: "insensitive" },
        },
        include: {
          assignedTo: {
            select: {
              id: true,
              name: true,
              avatar: true,
            },
          },
        },
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: "desc" },
      });

      const total = await prisma.task.count({
        where: {
          projectId: id,
          title: { contains: q, mode: "insensitive" },
        },
      });

      return paginatedResponse(res, tasks, total, page, limit);
    }

    return errorResponse(res, "Task or Project not found", 404);
  } catch (error) {
    console.error("Error fetching task or project tasks by ID:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// POST /tasks — create task
export const createTask = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;

    const validation = createTaskSchema.safeParse(req.body);
    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const {
      title,
      description,
      status,
      priority,
      dueDate,
      tags,
      projectId,
      assignedToId,
    } = validation.data;

    const project = await prisma.project.findUnique({
      where: { id: projectId },
    });

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    if (member.role === "VIEWER") {
      return errorResponse(res, "Viewers cannot create tasks", 403);
    }

    const parsedDueDate = dueDate ? new Date(dueDate) : null;

    const task = await prisma.task.create({
      data: {
        title,
        description,
        status: status || "TODO",
        priority: priority || "MEDIUM",
        dueDate: parsedDueDate,
        tags: tags || [],
        projectId,
        createdById: userId,
        assignedToId: assignedToId || null,
      },
    });

    // Log activity
    await prisma.activityLog.create({
      data: {
        action: "created this task",
        userId,
        taskId: task.id,
        projectId,
      },
    });

    // Notify assignee if assigned
    if (assignedToId) {
      await createNotification({
        userId: assignedToId,
        senderId: userId,
        type: "TASK_ASSIGNED",
        title: "Task Assigned",
        body: `You have been assigned the task: "${title}"`,
        taskId: task.id,
        projectId,
      });
    }

    // Emit Socket events
    io.to(`project:${projectId}`).emit("project:task_created", { task });

    return successResponse(res, task, "Task created successfully", 201);
  } catch (error) {
    console.error("Error creating task:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /tasks/project/:projectId — get tasks for project (original logic updated to standard response)
export const getTasks = async (req: AuthRequest, res: Response) => {
  try {
    const { projectId } = req.params;
    const userId = req.user!.userId;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const q = (req.query.q as string) || "";

    const project = await prisma.project.findUnique({
      where: { id: projectId },
    });

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    const tasks = await prisma.task.findMany({
      where: {
        projectId,
        title: { contains: q, mode: "insensitive" },
      },
      include: {
        assignedTo: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: "desc" },
    });

    const total = await prisma.task.count({
      where: {
        projectId,
        title: { contains: q, mode: "insensitive" },
      },
    });

    return paginatedResponse(res, tasks, total, page, limit);
  } catch (error) {
    console.error("Error fetching tasks:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// PATCH /tasks/:id — update task
export const updateTask = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const validation = updateTaskSchema.safeParse(req.body);
    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const task = await prisma.task.findUnique({ where: { id } });
    if (!task) {
      return errorResponse(res, "Task not found", 404);
    }

    const project = await prisma.project.findUnique({
      where: { id: task.projectId },
    });

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    if (member.role === "VIEWER") {
      return errorResponse(res, "Viewers cannot update tasks", 403);
    }

    if (member.role === "MEMBER" && task.createdById !== userId && task.assignedToId !== userId) {
      return errorResponse(res, "Members can only edit their own or assigned tasks", 403);
    }

    const {
      title,
      description,
      status,
      priority,
      dueDate,
      tags,
      assignedToId,
    } = validation.data;

    // Track changed fields to log activity & notify
    const activitiesToLog: string[] = [];

    if (title !== undefined && title !== task.title) {
      activitiesToLog.push(`changed title to "${title}"`);
    }
    if (description !== undefined && description !== task.description) {
      activitiesToLog.push(`changed description`);
    }
    if (status !== undefined && status !== task.status) {
      activitiesToLog.push(`changed status from ${task.status} to ${status}`);
    }
    if (priority !== undefined && priority !== task.priority) {
      activitiesToLog.push(`changed priority from ${task.priority} to ${priority}`);
    }
    if (dueDate !== undefined) {
      const oldTime = task.dueDate ? new Date(task.dueDate).getTime() : 0;
      const newTime = dueDate ? new Date(dueDate).getTime() : 0;
      if (oldTime !== newTime) {
        activitiesToLog.push(`changed due date to ${dueDate ? new Date(dueDate).toLocaleDateString() : "none"}`);
      }
    }
    if (assignedToId !== undefined && assignedToId !== task.assignedToId) {
      if (assignedToId) {
        const newAssignee = await prisma.user.findUnique({ where: { id: assignedToId } });
        activitiesToLog.push(`assigned task to ${newAssignee ? newAssignee.name : "another user"}`);
      } else {
        activitiesToLog.push(`removed assignee`);
      }
    }

    const parsedDueDate = dueDate === null ? null : dueDate ? new Date(dueDate) : undefined;

    const updatedTask = await prisma.task.update({
      where: { id },
      data: {
        title,
        description,
        status,
        priority,
        dueDate: parsedDueDate,
        tags,
        assignedToId,
      },
    });

    // Write activity logs
    if (activitiesToLog.length > 0) {
      await prisma.activityLog.createMany({
        data: activitiesToLog.map((action) => ({
          action,
          userId,
          taskId: id,
          projectId: task.projectId,
        })),
      });
    }

    // Trigger Notification for Assignee if assigned changed
    if (assignedToId && assignedToId !== task.assignedToId) {
      await createNotification({
        userId: assignedToId,
        senderId: userId,
        type: "TASK_ASSIGNED",
        title: "Task Assigned",
        body: `You have been assigned to: "${updatedTask.title}"`,
        taskId: id,
        projectId: task.projectId,
      });
    }

    // Trigger Notification for Status change
    if (status !== undefined && status !== task.status) {
      const notifyUsers = new Set<string>();
      if (task.createdById !== userId) notifyUsers.add(task.createdById);
      if (task.assignedToId && task.assignedToId !== userId) notifyUsers.add(task.assignedToId);
      if (assignedToId && assignedToId !== userId) notifyUsers.add(assignedToId);

      await Promise.all(
        Array.from(notifyUsers).map((rId) =>
          createNotification({
            userId: rId,
            senderId: userId,
            type: "TASK_STATUS_CHANGED",
            title: "Task Status Changed",
            body: `Status of "${updatedTask.title}" was changed to ${status}`,
            taskId: id,
            projectId: task.projectId,
          })
        )
      );
    }

    // Emit Socket events
    io.to(`task:${id}`).emit("task:updated", { taskId: id, changes: validation.data });
    io.to(`project:${task.projectId}`).emit("project:task_updated", { taskId: id });

    return successResponse(res, updatedTask, "Task updated successfully");
  } catch (error) {
    console.error("Error updating task:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// DELETE /tasks/:id — delete task (creator or project owner only)
export const deleteTask = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const task = await prisma.task.findUnique({ where: { id } });
    if (!task) {
      return errorResponse(res, "Task not found", 404);
    }

    const project = await prisma.project.findUnique({
      where: { id: task.projectId },
    });

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    const isCreator = task.createdById === userId;
    const isProjectOwner = project.ownerId === userId;
    const isTeamOwnerOrAdmin = ["OWNER", "ADMIN"].includes(member.role);

    if (!isCreator && !isProjectOwner && !isTeamOwnerOrAdmin) {
      return errorResponse(res, "Access denied. Only the task creator, project owner, or team admins/owners can delete this task.", 403);
    }

    await prisma.task.delete({ where: { id } });

    // Log activity
    await prisma.activityLog.create({
      data: {
        action: `deleted task "${task.title}"`,
        userId,
        projectId: task.projectId,
      },
    });

    // Emit Socket events
    io.to(`project:${task.projectId}`).emit("project:task_deleted", { taskId: id });

    return successResponse(res, null, "Task deleted successfully");
  } catch (error) {
    console.error("Error deleting task:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
