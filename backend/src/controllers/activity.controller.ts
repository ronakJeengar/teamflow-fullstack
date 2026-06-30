import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";

// GET /activities/tasks/:taskId — list activity log for a task
export const getTaskActivities = async (req: AuthRequest, res: Response) => {
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

    const activities = await prisma.activityLog.findMany({
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
      orderBy: { createdAt: "desc" },
    });

    return successResponse(res, activities);
  } catch (error) {
    console.error("Error fetching task activities:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /activities/projects/:projectId — project-level activity
export const getProjectActivities = async (req: AuthRequest, res: Response) => {
  try {
    const { projectId } = req.params;
    const userId = req.user!.userId;

    const project = await prisma.project.findUnique({
      where: { id: projectId },
      select: {
        teamId: true,
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

    const activities = await prisma.activityLog.findMany({
      where: { projectId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return successResponse(res, activities);
  } catch (error) {
    console.error("Error fetching project activities:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /activities/workspaces/:workspaceId — workspace-level timeline
export const getWorkspaceActivities = async (req: AuthRequest, res: Response) => {
  try {
    const { workspaceId } = req.params;
    const userId = req.user!.userId;

    const isMember = await prisma.workspaceMember.findUnique({
      where: {
        workspaceId_userId: {
          workspaceId,
          userId,
        },
      },
    });

    if (!isMember) {
      return errorResponse(res, "Access denied. Not a workspace member.", 403);
    }

    const teams = await prisma.team.findMany({ where: { workspaceId } });
    const teamIds = teams.map(t => t.id);

    const projects = await prisma.project.findMany({ where: { teamId: { in: teamIds } } });
    const projectIds = projects.map(p => p.id);

    const tasks = await prisma.task.findMany({ where: { projectId: { in: projectIds } } });
    const taskIds = tasks.map(t => t.id);

    const activities = await prisma.activityLog.findMany({
      where: {
        OR: [
          { teamId: { in: teamIds } },
          { projectId: { in: projectIds } },
          { taskId: { in: taskIds } },
        ],
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
      orderBy: { createdAt: "desc" },
      take: 50,
    });

    return successResponse(res, activities);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};

// GET /activities/teams/:teamId — team-level timeline
export const getTeamActivities = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const userId = req.user!.userId;

    const isMember = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId,
          userId,
        },
      },
    });

    if (!isMember) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    const projects = await prisma.project.findMany({ where: { teamId } });
    const projectIds = projects.map(p => p.id);

    const tasks = await prisma.task.findMany({ where: { projectId: { in: projectIds } } });
    const taskIds = tasks.map(t => t.id);

    const activities = await prisma.activityLog.findMany({
      where: {
        OR: [
          { teamId },
          { projectId: { in: projectIds } },
          { taskId: { in: taskIds } },
        ],
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
      orderBy: { createdAt: "desc" },
      take: 50,
    });

    return successResponse(res, activities);
  } catch (error: any) {
    return errorResponse(res, error.message);
  }
};
