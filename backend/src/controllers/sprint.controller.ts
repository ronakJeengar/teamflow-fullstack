import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { createNotification } from "./notification.controller.js";

// GET /sprints
export const getSprints = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId, projectId } = req.query;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    if (!activeWorkspaceId) {
      return errorResponse(res, "Active workspace not set", 400);
    }

    const whereClause: any = { workspaceId: activeWorkspaceId };
    if (teamId) {
      whereClause.teamId = teamId as string;
    }
    if (projectId) {
      whereClause.projects = { some: { id: projectId as string } };
    }

    const sprints = await prisma.sprint.findMany({
      where: whereClause,
      orderBy: { startDate: "asc" }
    });

    return successResponse(res, sprints);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// POST /sprints
export const createSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { name, goal, startDate, endDate, teamId, projectId } = req.body;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    if (!activeWorkspaceId) {
      return errorResponse(res, "Active workspace not set", 400);
    }
    if (!name || !startDate || !endDate || !teamId) {
      return errorResponse(res, "Name, startDate, endDate, and teamId are required", 400);
    }

    // Verify team belongs to active workspace
    const team = await prisma.team.findFirst({
      where: { id: teamId, workspaceId: activeWorkspaceId }
    });
    if (!team) {
      return errorResponse(res, "Team not found in active workspace", 404);
    }

    const start = new Date(startDate);
    const end = new Date(endDate);
    if (end < start) {
      return errorResponse(res, "End date must be on or after start date", 400);
    }

    const sprint = await prisma.sprint.create({
      data: {
        name,
        goal,
        startDate: start,
        endDate: end,
        status: "PLANNED",
        teamId,
        workspaceId: activeWorkspaceId,
        createdById: req.user!.userId,
        projects: projectId ? { connect: { id: projectId } } : undefined
      }
    });

    return successResponse(res, sprint, "Sprint created successfully", 201);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// GET /sprints/:id
export const getSprintById = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      },
      include: {
        tasks: true,
        projects: true
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    return successResponse(res, sprint);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// PATCH /sprints/:id
export const updateSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { name, goal, startDate, endDate, status, projectId } = req.body;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    if (sprint.status === "COMPLETED") {
      return errorResponse(res, "Completed sprints are read-only", 400);
    }

    if (startDate || endDate) {
      const start = startDate ? new Date(startDate) : new Date(sprint.startDate);
      const end = endDate ? new Date(endDate) : new Date(sprint.endDate);
      if (end < start) {
        return errorResponse(res, "End date must be on or after start date", 400);
      }
    }

    if (status === "ACTIVE") {
      const activeSprint = await prisma.sprint.findFirst({
        where: {
          teamId: sprint.teamId,
          status: "ACTIVE",
          id: { not: id }
        }
      });
      if (activeSprint) {
        return errorResponse(res, "There is already an active sprint in this team", 400);
      }
    }

    const updated = await prisma.sprint.update({
      where: { id },
      data: {
        name,
        goal,
        startDate: startDate ? new Date(startDate) : undefined,
        endDate: endDate ? new Date(endDate) : undefined,
        status,
        projects: projectId ? { connect: { id: projectId } } : undefined
      }
    });

    return successResponse(res, updated);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// DELETE /sprints/:id
export const deleteSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    if (sprint.status === "ACTIVE") {
      return errorResponse(res, "Cannot delete an active sprint", 400);
    }

    if (sprint.status === "COMPLETED") {
      return errorResponse(res, "Completed sprints cannot be deleted", 400);
    }

    await prisma.sprint.delete({
      where: { id }
    });

    return successResponse(res, { message: "Sprint deleted successfully" });
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// GET /sprints/:id/tasks
export const getSprintTasks = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: { id, workspaceId: activeWorkspaceId }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    const tasks = await prisma.task.findMany({
      where: { sprintId: id }
    });

    return successResponse(res, tasks);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// POST /sprints/:id/tasks (Assign)
export const assignTasksToSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { taskIds } = req.body;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    if (!Array.isArray(taskIds)) {
      return errorResponse(res, "taskIds must be an array of strings", 400);
    }

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    if (sprint.status === "COMPLETED") {
      return errorResponse(res, "Cannot assign tasks to a completed sprint", 400);
    }

    // Verify tasks belong to active workspace
    const tasksCount = await prisma.task.count({
      where: {
        id: { in: taskIds },
        project: { team: { workspaceId: activeWorkspaceId } }
      }
    });

    if (tasksCount !== taskIds.length) {
      return errorResponse(res, "Some tasks are not found in this workspace", 400);
    }

    await prisma.task.updateMany({
      where: {
        id: { in: taskIds }
      },
      data: {
        sprintId: id
      }
    });

    const tasks = await prisma.task.findMany({
      where: { id: { in: taskIds } }
    });

    for (const task of tasks) {
      if (task.assignedToId) {
        await createNotification({
          userId: task.assignedToId,
          senderId: req.user!.userId,
          type: "TASK_MOVED_TO_SPRINT",
          title: "Task Assigned to Sprint",
          body: `Task "${task.title}" has been assigned to sprint "${sprint.name}"`,
          taskId: task.id,
          projectId: task.projectId
        });
      }
    }

    return successResponse(res, { message: "Tasks assigned to sprint successfully" });
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// DELETE /sprints/:id/tasks/:taskId
export const removeTaskFromSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { id, taskId } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    if (sprint.status === "COMPLETED") {
      return errorResponse(res, "Cannot remove tasks from a completed sprint", 400);
    }

    const task = await prisma.task.findFirst({
      where: {
        id: taskId,
        sprintId: id
      }
    });

    if (!task) {
      return errorResponse(res, "Task not found in this sprint", 404);
    }

    await prisma.task.update({
      where: { id: taskId },
      data: { sprintId: null }
    });

    return successResponse(res, { message: "Task removed from sprint successfully" });
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// POST /sprints/:id/start
export const startSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    const activeSprint = await prisma.sprint.findFirst({
      where: {
        teamId: sprint.teamId,
        status: "ACTIVE"
      }
    });

    if (activeSprint) {
      return errorResponse(res, "There is already an active sprint in this team", 400);
    }

    const updated = await prisma.sprint.update({
      where: { id },
      data: { status: "ACTIVE" }
    });

    // Notify team members: SPRINT_STARTED
    const members = await prisma.teamMember.findMany({
      where: { teamId: sprint.teamId }
    });

    for (const member of members) {
      await createNotification({
        userId: member.userId,
        senderId: req.user!.userId,
        type: "SPRINT_STARTED",
        title: "Sprint Started",
        body: `Sprint "${sprint.name}" has been started.`,
        teamId: sprint.teamId
      });
    }

    return successResponse(res, updated);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// POST /sprints/:id/complete
export const completeSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const force = req.body.force === true || req.body.force === "true";
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      },
      include: {
        tasks: true
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    const openTasks = sprint.tasks.filter(t => t.status !== "DONE");

    if (openTasks.length > 0 && !force) {
      return errorResponse(res, "Cannot complete sprint with open tasks. Use force=true to move them to backlogs.", 400);
    }

    if (openTasks.length > 0) {
      await prisma.task.updateMany({
        where: {
          id: { in: openTasks.map(t => t.id) }
        },
        data: {
          sprintId: null
        }
      });
    }

    const updated = await prisma.sprint.update({
      where: { id },
      data: { status: "COMPLETED" }
    });

    // Notify team members: SPRINT_COMPLETED
    const members = await prisma.teamMember.findMany({
      where: { teamId: sprint.teamId }
    });

    for (const member of members) {
      await createNotification({
        userId: member.userId,
        senderId: req.user!.userId,
        type: "SPRINT_COMPLETED",
        title: "Sprint Completed",
        body: `Sprint "${sprint.name}" has been completed.`,
        teamId: sprint.teamId
      });
    }

    return successResponse(res, updated);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// GET /sprints/:id/stats
export const getSprintStats = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      },
      include: {
        tasks: true
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    const totalTasks = sprint.tasks.length;
    const completedTasks = sprint.tasks.filter(t => t.status === "DONE").length;
    const remainingTasks = totalTasks - completedTasks;
    const completionPercent = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

    const now = new Date();
    const overdueTasks = sprint.tasks.filter(t => t.status !== "DONE" && t.dueDate && new Date(t.dueDate) < now).length;

    const priorityWeights: Record<string, number> = {
      LOW: 1,
      MEDIUM: 3,
      HIGH: 5,
      URGENT: 8
    };

    const totalPoints = sprint.tasks.reduce((sum, t) => sum + (priorityWeights[t.priority] || 3), 0);
    const completedPoints = sprint.tasks.filter(t => t.status === "DONE").reduce((sum, t) => sum + (priorityWeights[t.priority] || 3), 0);

    // Compute Velocity
    const completedSprints = await prisma.sprint.findMany({
      where: {
        teamId: sprint.teamId,
        status: "COMPLETED"
      },
      include: {
        tasks: {
          where: { status: "DONE" }
        }
      },
      orderBy: { endDate: "desc" },
      take: 5
    });

    const velocities = completedSprints.map(s => 
      s.tasks.reduce((sum, t) => sum + (priorityWeights[t.priority] || 3), 0)
    );
    const velocity = velocities.length > 0 ? Math.round(velocities.reduce((sum, v) => sum + v, 0) / velocities.length) : 0;

    // Compute daily progress and sparkline
    const start = new Date(sprint.startDate);
    const end = new Date(sprint.endDate);
    const days: string[] = [];
    let current = new Date(start);
    const maxDay = now < end ? now : end;
    while (current <= maxDay) {
      days.push(current.toISOString().split("T")[0]);
      current.setDate(current.getDate() + 1);
    }
    if (days.length === 0) {
      days.push(start.toISOString().split("T")[0]);
    }

    const sparkline = days.map((dayStr) => {
      const dayDate = new Date(dayStr);
      dayDate.setHours(23, 59, 59, 999);
      const remaining = sprint.tasks.filter(t => {
        if (t.status !== "DONE") return true;
        return new Date(t.updatedAt) > dayDate;
      }).length;
      return remaining;
    });

    // Trend calculation: ON_TRACK if actual remaining <= ideal remaining, else BEHIND
    let trend = "ON_TRACK";
    if (days.length > 0) {
      const currentDayIndex = days.length - 1;
      const totalSprintDays = Math.max(1, Math.round((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)));
      const idealRemaining = Math.max(0, totalTasks - (totalTasks / totalSprintDays) * currentDayIndex);
      const currentRemaining = sparkline[sparkline.length - 1] ?? remainingTasks;
      trend = currentRemaining <= idealRemaining ? "ON_TRACK" : "BEHIND";
    }

    return successResponse(res, {
      totalTasks,
      completedTasks,
      remainingTasks,
      completionPercent,
      velocity,
      overdueTasks,
      totalPoints,
      completedPoints,
      trend,
      sparkline,
    });
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// GET /sprints/:id/burndown
export const getSprintBurndown = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      },
      include: {
        tasks: true
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    const start = new Date(sprint.startDate);
    const end = new Date(sprint.endDate);

    const days: string[] = [];
    let current = new Date(start);
    while (current <= end) {
      days.push(current.toISOString().split("T")[0]);
      current.setDate(current.getDate() + 1);
    }

    if (days.length === 0) {
      days.push(start.toISOString().split("T")[0]);
      days.push(end.toISOString().split("T")[0]);
    }

    const totalTasks = sprint.tasks.length;

    const burndownData = days.map((dayStr, index) => {
      const dayDate = new Date(dayStr);
      dayDate.setHours(23, 59, 59, 999);

      const remainingTasks = sprint.tasks.filter(t => {
        if (t.status !== "DONE") return true;
        return new Date(t.updatedAt) > dayDate;
      }).length;

      const idealRemaining = Math.max(0, totalTasks - (totalTasks / (days.length - 1)) * index);

      return {
        date: dayStr,
        actual: remainingTasks,
        ideal: Math.round(idealRemaining * 100) / 100
      };
    });

    return successResponse(res, burndownData);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// GET /sprints/:id/velocity
export const getSprintVelocity = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    const completedSprints = await prisma.sprint.findMany({
      where: {
        teamId: sprint.teamId,
        status: "COMPLETED"
      },
      include: {
        tasks: {
          where: { status: "DONE" }
        }
      },
      orderBy: { endDate: "desc" },
      take: 5
    });

    const priorityWeights: Record<string, number> = {
      LOW: 1,
      MEDIUM: 3,
      HIGH: 5,
      URGENT: 8
    };

    const velocities = completedSprints.map(s => {
      const completedPoints = s.tasks.reduce((sum, t) => sum + (priorityWeights[t.priority] || 3), 0);
      return {
        sprintId: s.id,
        sprintName: s.name,
        completedPoints
      };
    });

    const totalPointsCompleted = velocities.reduce((sum, v) => sum + v.completedPoints, 0);
    const averageVelocity = completedSprints.length > 0 ? Math.round(totalPointsCompleted / completedSprints.length) : 0;

    return successResponse(res, {
      averageVelocity,
      history: velocities
    });
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// POST /sprints/:id/cancel
export const cancelSprint = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const sprint = await prisma.sprint.findFirst({
      where: {
        id,
        workspaceId: activeWorkspaceId
      }
    });

    if (!sprint) {
      return errorResponse(res, "Sprint not found in active workspace", 404);
    }

    if (sprint.status === "COMPLETED") {
      return errorResponse(res, "Cannot cancel a completed sprint", 400);
    }

    const updated = await prisma.sprint.update({
      where: { id },
      data: { status: "CANCELLED" }
    });

    return successResponse(res, updated);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};
