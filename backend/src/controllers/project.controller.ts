import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";

export const createProject = async (req: AuthRequest, res: Response) => {
  try {
    const { name, description, avatar, color, visibility, startDate, dueDate } = req.body;
    const teamId = (req.body.teamId || req.params.teamId || req.query.teamId) as string | undefined;

    if (!teamId) {
      return errorResponse(res, "Team ID is required", 400);
    }

    if (!name) {
      return errorResponse(res, "Project name is required", 400);
    }
    const userId = req.user!.userId;

    const member = await prisma.teamMember.findFirst({
      where: { teamId, userId },
    });

    if (!member) {
      return errorResponse(res, "Not a team member", 403);
    }

    // Only OWNER and ADMIN can create projects
    if (!["OWNER", "ADMIN"].includes(member.role)) {
      return errorResponse(res, "Only admins and owners can create projects", 403);
    }

    const project = await prisma.project.create({
      data: {
        name,
        description,
        avatar,
        color,
        visibility: visibility || "PRIVATE",
        startDate: startDate ? new Date(startDate) : null,
        dueDate: dueDate ? new Date(dueDate) : null,
        teamId,
        ownerId: userId,
      },
    });

    // Log Activity
    await prisma.activityLog.create({
      data: {
        action: `created project "${name}"`,
        userId,
        projectId: project.id,
      },
    });

    return successResponse(res, project, "Project created successfully", 201);
  } catch (error) {
    console.error("Error creating project:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /projects — list projects for current user's teams
export const getProjects = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const teamId = (req.query.teamId || req.params.teamId) as string | undefined;
    const status = req.query.status as string | undefined;
    const workspaceId = req.query.workspaceId as string | undefined;

    const whereClause: any = {
      team: {
        members: {
          some: { userId },
        },
      },
    };

    if (teamId) {
      whereClause.teamId = teamId;
    }

    if (status) {
      whereClause.status = status;
    }

    if (workspaceId) {
      whereClause.team.workspaceId = workspaceId;
    }

    const projects = await prisma.project.findMany({
      where: whereClause,
      include: {
        team: {
          select: {
            id: true,
            name: true,
            workspaceId: true,
          },
        },
        owner: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        _count: {
          select: {
            tasks: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    const projectIds = projects.map((p) => p.id);

    let completedMap = new Map<string, number>();
    if (projectIds.length > 0) {
      const completedTaskCounts = await prisma.task.groupBy({
        by: ["projectId"],
        where: {
          projectId: { in: projectIds },
          status: "DONE",
        },
        _count: {
          id: true,
        },
      });
      completedMap = new Map(completedTaskCounts.map((c) => [c.projectId, c._count.id]));
    }

    const formattedProjects = projects.map((project) => {
      const totalTasks = project._count.tasks;
      const completedTasks = completedMap.get(project.id) || 0;
      const progressPercent = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

      const { _count, ...rest } = project;
      return {
        ...rest,
        progress: progressPercent,
        totalTasks,
        completedTasks,
      };
    });

    return successResponse(res, formattedProjects, "Projects fetched successfully");
  } catch (error) {
    console.error("Error fetching projects:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /projects/:id — project detail
export const getProjectById = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const project = await prisma.project.findUnique({
      where: { id },
      include: {
        tasks: {
          orderBy: { createdAt: "desc" },
          take: 5,
          include: {
            assignedTo: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
          },
        },
        team: {
          include: {
            members: {
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
        },
        owner: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    const isMember = project.team.members.some((m) => m.userId === userId);
    if (!isMember) {
      return errorResponse(res, "Access denied. Not a team member.", 403);
    }

    const activities = await prisma.activityLog.findMany({
      where: { projectId: id },
      orderBy: { createdAt: "desc" },
      take: 5,
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

    return successResponse(
      res,
      {
        ...project,
        activity: activities,
      },
      "Project details fetched successfully"
    );
  } catch (error) {
    console.error("Error fetching project details:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

export const updateProject = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { name, description, avatar, color, status, visibility, startDate, dueDate } = req.body;
    const userId = req.user!.userId;

    const project = await prisma.project.findUnique({ where: { id } });
    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) {
      return errorResponse(res, "Not a team member", 403);
    }

    // Only OWNER and ADMIN can update projects
    if (!["OWNER", "ADMIN"].includes(member.role)) {
      return errorResponse(res, "Only admins and owners can update projects", 403);
    }

    const updatedProject = await prisma.project.update({
      where: { id },
      data: {
        name,
        description,
        avatar,
        color,
        status,
        visibility,
        startDate: startDate ? new Date(startDate) : undefined,
        dueDate: dueDate ? new Date(dueDate) : undefined,
      },
    });

    // Log Activity
    await prisma.activityLog.create({
      data: {
        action: `updated project "${updatedProject.name}"`,
        userId,
        projectId: id,
      },
    });

    return successResponse(res, updatedProject, "Project updated successfully");
  } catch (error) {
    console.error("Error updating project:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

export const deleteProject = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const project = await prisma.project.findUnique({ where: { id } });
    if (!project) {
      return errorResponse(res, "Project not found", 404);
    }

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) {
      return errorResponse(res, "Not a team member", 403);
    }

    // Only OWNER and ADMIN can delete projects
    if (!["OWNER", "ADMIN"].includes(member.role)) {
      return errorResponse(res, "Only admins and owners can delete projects", 403);
    }

    await prisma.project.delete({ where: { id } });

    // Log Activity
    await prisma.activityLog.create({
      data: {
        action: `deleted project "${project.name}"`,
        userId,
      },
    });

    return successResponse(res, null, "Project deleted successfully");
  } catch (error) {
    console.error("Error deleting project:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
