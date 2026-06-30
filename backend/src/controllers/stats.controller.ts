import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";

// GET /stats/dashboard — My Work stats for current user
export const getDashboardStats = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    let activeWorkspaceId = req.user?.activeWorkspaceId;

    if (!activeWorkspaceId) {
      // Fallback: find user's first workspace membership or ownership
      const workspaceMember = await prisma.workspaceMember.findFirst({
        where: { userId },
      });
      activeWorkspaceId = workspaceMember?.workspaceId;
    }

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayEnd = new Date(todayStart);
    todayEnd.setHours(23, 59, 59, 999);

    const weekStart = new Date(todayStart);
    weekStart.setDate(todayStart.getDate() - 6);

    const taskFilter: any = { assignedToId: userId };
    if (activeWorkspaceId) {
      taskFilter.project = {
        team: {
          workspaceId: activeWorkspaceId,
        },
      };
    }

    const [statusGroups, tasksDueToday, completedThisWeek, sparklineTasks] = await Promise.all([
      prisma.task.groupBy({
        by: ['status'],
        where: taskFilter,
        _count: { _all: true },
      }),
      prisma.task.count({
        where: {
          ...taskFilter,
          dueDate: {
            gte: todayStart,
            lte: todayEnd,
          },
        },
      }),
      prisma.task.count({
        where: {
          ...taskFilter,
          status: "DONE",
          updatedAt: {
            gte: weekStart,
          },
        },
      }),
      prisma.task.findMany({
        where: {
          ...taskFilter,
          OR: [
            {
              dueDate: {
                gte: weekStart,
                lte: todayEnd,
              },
            },
            {
              updatedAt: {
                gte: weekStart,
                lte: todayEnd,
              },
            },
          ],
        },
        select: {
          dueDate: true,
          updatedAt: true,
          status: true,
        },
      }),
    ]);

    let inProgress = 0;
    let inReview = 0;
    let blocked = 0;
    for (const group of statusGroups) {
      if (group.status === "IN_PROGRESS") inProgress = group._count._all;
      else if (group.status === "REVIEW") inReview = group._count._all;
      else if (group.status === "BLOCKED") blocked = group._count._all;
    }

    const sparklines = {
      tasksDueToday: [0, 0, 0, 0, 0, 0, 0],
      inProgress: [0, 0, 0, 0, 0, 0, 0],
      inReview: [0, 0, 0, 0, 0, 0, 0],
      blocked: [0, 0, 0, 0, 0, 0, 0],
    };

    for (let i = 0; i < 7; i++) {
      const dayStart = new Date(weekStart);
      dayStart.setDate(weekStart.getDate() + i);
      const dayEnd = new Date(dayStart);
      dayEnd.setHours(23, 59, 59, 999);

      for (const task of sparklineTasks) {
        // Due today check
        if (task.dueDate) {
          const due = new Date(task.dueDate);
          if (due >= dayStart && due <= dayEnd) {
            sparklines.tasksDueToday[i]++;
          }
        }

        // Status trend check
        if (task.updatedAt) {
          const updated = new Date(task.updatedAt);
          if (updated <= dayEnd) {
            if (task.status === "IN_PROGRESS" && updated >= dayStart) {
              sparklines.inProgress[i]++;
            } else if (task.status === "REVIEW" && updated >= dayStart) {
              sparklines.inReview[i]++;
            } else if (task.status === "BLOCKED" && updated >= dayStart) {
              sparklines.blocked[i]++;
            }
          }
        }
      }
    }

    // Aggregations for workspace and project metrics
    const teamWhereClause: any = { userId };
    if (activeWorkspaceId) {
      teamWhereClause.team = {
        workspaceId: activeWorkspaceId,
      };
    }

    const userTeams = await prisma.teamMember.findMany({
      where: teamWhereClause,
      select: { teamId: true },
    });
    const teamIds = userTeams.map((ut) => ut.teamId);

    const projects = await prisma.project.findMany({
      where: { teamId: { in: teamIds } },
      select: { id: true },
    });
    const projectIds = projects.map((p) => p.id);
    const project_count = projects.length;

    const membersCountResult = await prisma.teamMember.groupBy({
      by: ['userId'],
      where: { teamId: { in: teamIds } },
    });
    const member_count = membersCountResult.length;

    const task_count = await prisma.task.count({
      where: { projectId: { in: projectIds } },
    });

    const taskCountPerProjectQuery = await prisma.task.groupBy({
      by: ['projectId'],
      where: { projectId: { in: projectIds } },
      _count: { id: true },
    });
    const task_count_per_project = taskCountPerProjectQuery.map((t) => ({
      projectId: t.projectId,
      count: t._count.id,
    }));

    const active_tasks_count = await prisma.task.count({
      where: {
        assignedToId: userId,
        NOT: { status: "DONE" },
        project: activeWorkspaceId
          ? {
              team: {
                workspaceId: activeWorkspaceId,
              },
            }
          : undefined,
      },
    });
    const completed_tasks_count = await prisma.task.count({
      where: {
        assignedToId: userId,
        status: "DONE",
        project: activeWorkspaceId
          ? {
              team: {
                workspaceId: activeWorkspaceId,
              },
            }
          : undefined,
      },
    });

    // Sprint Dashboard Integration
    const currentActiveSprint = activeWorkspaceId
      ? await prisma.sprint.findFirst({
          where: {
            status: "ACTIVE",
            workspaceId: activeWorkspaceId,
          },
          include: {
            tasks: true,
          },
        })
      : null;

    let sprintProgress: any = null;
    let sprintVelocity = 0;

    if (currentActiveSprint) {
      const totalTasks = currentActiveSprint.tasks.length;
      const completedTasks = currentActiveSprint.tasks.filter((t) => t.status === "DONE").length;
      const completionPercentage = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

      sprintProgress = {
        totalTasks,
        completedTasks,
        completionPercentage,
      };

      const completedSprints = await prisma.sprint.findMany({
        where: {
          teamId: currentActiveSprint.teamId,
          status: "COMPLETED",
        },
        include: {
          tasks: {
            where: { status: "DONE" },
          },
        },
      });

      const priorityWeights: Record<string, number> = {
        LOW: 1,
        MEDIUM: 3,
        HIGH: 5,
        URGENT: 8,
      };

      const totalCompletedPoints = completedSprints.reduce((sum, s) => {
        return sum + s.tasks.reduce((tsum: number, t) => tsum + (priorityWeights[t.priority] || 3), 0);
      }, 0);

      sprintVelocity = completedSprints.length > 0 ? Math.round(totalCompletedPoints / completedSprints.length) : 0;
    }

    const team_count = activeWorkspaceId
      ? await prisma.team.count({ where: { workspaceId: activeWorkspaceId } })
      : 0;

    return successResponse(res, {
      tasksDueToday,
      inProgress,
      inReview,
      blocked,
      completedThisWeek,
      sparklines,
      project_count,
      member_count,
      team_count,
      task_count,
      task_count_per_project,
      active_tasks_count,
      completed_tasks_count,
      currentSprint: currentActiveSprint,
      sprintProgress,
      sprintVelocity,
    });
  } catch (error) {
    console.error("Error calculating dashboard stats:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /stats/project/:projectId — project stats
export const getProjectStats = async (req: AuthRequest, res: Response) => {
  try {
    const { projectId } = req.params;
    const userId = req.user!.userId;

    const project = await prisma.project.findUnique({
      where: { id: projectId },
      select: {
        teamId: true,
        updatedAt: true,
      },
    });

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    // Verify user is in the team using compound unique index
    const isMember = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId: project.teamId,
          userId,
        },
      },
    });
    if (!isMember) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    const [taskStats, completedTasks, memberCount] = await Promise.all([
      prisma.task.aggregate({
        where: { projectId },
        _count: { _all: true },
        _max: { updatedAt: true },
      }),
      prisma.task.count({
        where: { projectId, status: "DONE" },
      }),
      prisma.teamMember.count({
        where: { teamId: project.teamId },
      }),
    ]);

    const totalTasks = taskStats._count._all;
    const progressPercent = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;
    const lastUpdated = taskStats._max.updatedAt && taskStats._max.updatedAt > project.updatedAt
      ? taskStats._max.updatedAt
      : project.updatedAt;

    return successResponse(res, {
      totalTasks,
      completedTasks,
      progressPercent,
      memberCount,
      lastUpdated,
    });
  } catch (error) {
    console.error("Error calculating project stats:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
