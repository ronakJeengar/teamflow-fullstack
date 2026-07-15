import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { TeamMemberRole } from "@prisma/client";

// Create a new team
export const createTeam = async (req: AuthRequest, res: Response) => {
  try {
    const { name, description, avatar, workspaceId } = req.body;
    const userId = req.user!.userId;

    if (!name) {
      return errorResponse(res, "Team name is required", 400);
    }

    let targetWorkspaceId = workspaceId || req.user?.activeWorkspaceId;

    if (!targetWorkspaceId) {
      const workspaceMember = await prisma.workspaceMember.findFirst({
        where: { userId },
      });
      targetWorkspaceId = workspaceMember?.workspaceId;
    }

    if (targetWorkspaceId) {
      const workspace = await prisma.workspace.findUnique({
        where: { id: targetWorkspaceId },
        include: {
          members: {
            where: { userId },
          },
        },
      });

      if (!workspace) {
        return errorResponse(res, "Workspace not found", 404);
      }

      const isWsMember =
        workspace.ownerId === userId || workspace.members.length > 0;
      if (!isWsMember) {
        return errorResponse(res, "Access denied. Not a member of this workspace.", 403);
      }
    }

    const team = await prisma.team.create({
      data: {
        name,
        description,
        avatar,
        ownerId: userId,
        workspaceId: targetWorkspaceId || null,
        members: {
          create: {
            userId,
            role: TeamMemberRole.OWNER,
          },
        },
      },
      include: { members: true },
    });

    return successResponse(res, team, "Team created successfully", 201);
  } catch (error) {
    console.error("Error creating team:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// Get all teams where the user is a member
export const getMyTeams = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const workspaceId = req.query.workspaceId as string | undefined;

    const whereClause: any = {
      userId,
    };

    if (workspaceId) {
      whereClause.team = {
        workspaceId,
      };
    }

    const memberships = await prisma.teamMember.findMany({
      where: whereClause,
      include: {
        team: {
          include: {
            members: {
              include: {
                user: {
                  select: {
                    id: true,
                    name: true,
                    email: true,
                    avatar: true,
                  },
                },
              },
            },
            projects: {
              include: {
                _count: {
                  select: { tasks: true },
                },
              },
            },
          },
        },
      },
    });

    const teams = memberships.map((m) => m.team);
    return successResponse(res, teams, "Teams retrieved successfully");
  } catch (error) {
    console.error("Error fetching teams:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// Get detailed info of a specific team
export const getTeamDetails = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const { teamId } = req.params;

    const team = await prisma.team.findUnique({
      where: { id: teamId },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                avatar: true,
              },
            },
          },
        },
        projects: {
          include: {
            _count: {
              select: { tasks: true },
            },
          },
        },
      },
    });

    if (!team) {
      return errorResponse(res, "Team not found", 404);
    }

    const isOwner = team.ownerId === userId;
    const isMember = team.members.some((m) => m.userId === userId);

    if (!isOwner && !isMember) {
      return errorResponse(res, "Access Denied", 403);
    }

    return successResponse(res, team, "Team details retrieved successfully");
  } catch (error) {
    console.error("Get Team Details error:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// Update a team (only OWNER can update)
export const updateTeam = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const { name, description, avatar, workspaceId } = req.body;
    const userId = req.user!.userId;

    const team = await prisma.team.findUnique({ where: { id: teamId } });
    if (!team) {
      return errorResponse(res, "Team not found", 404);
    }

    if (team.ownerId !== userId) {
      return errorResponse(res, "Not allowed to update this team", 403);
    }

    const updatedTeam = await prisma.team.update({
      where: { id: teamId },
      data: {
        name,
        description,
        avatar,
        workspaceId: workspaceId !== undefined ? workspaceId : undefined,
      },
    });

    return successResponse(res, updatedTeam, "Team updated successfully");
  } catch (err: any) {
    console.error("Update error:", err);
    return errorResponse(res, "Internal server error", 500);
  }
};

// Delete a team (only OWNER can delete)
export const deleteTeam = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const userId = req.user!.userId;
    const team = await prisma.team.findUnique({ where: { id: teamId } });

    if (!team) {
      return errorResponse(res, "Team not found", 404);
    }

    if (team.ownerId !== String(userId)) {
      return errorResponse(res, "Not allowed to delete this team", 403);
    }

    const deletedTeam = await prisma.team.delete({ where: { id: teamId } });

    return successResponse(res, deletedTeam, "Team deleted successfully");
  } catch (err: any) {
    console.error("Delete error:", err);
    return errorResponse(res, "Internal server error", 500);
  }
};
