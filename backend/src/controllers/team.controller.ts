import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { failure, success } from "../utils/response.js";

export type TeamMemberRole = "OWNER" | "ADMIN" | "MEMBER" | "VIEWER";

// Create a new team
export const createTeam = async (req: AuthRequest, res: Response) => {
  try {
    const { name, description, avatar } = req.body;
    const userId = req.user!.userId;

    if (!name) return failure(res, "Team name is required", 400);

    const team = await prisma.team.create({
      data: {
        name,
        description,
        avatar,
        ownerId: userId,
        members: {
          create: {
            userId,
            role: "OWNER" as TeamMemberRole,
          },
        },
      },
      include: { members: true },
    });
    return success(res, "Team created successfully", team, 201);
  } catch (error) {
    console.error("Error creating team:", error);
    return failure(res, "Internal server error", 500);
  }
};

// Get all teams where the user is a member
export const getMyTeams = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;

    const memberships = await prisma.teamMember.findMany({
      where: { userId },
      include: { team: true },
    });

    const teams = memberships.map((m) => m.team);
    success(res, "Teams retrieved successfully", teams);
  } catch (error) {
    console.error("Error fetching teams:", error);
    return failure(res, "Internal server error", 500);
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
        members: { include: { user: true } },
        projects: true,
        invitations: true,
      },
    });

    if (!team) return failure(res, "Team not found", 404);

    const isOwner = team.ownerId === userId;
    const isMember = team.members.some((m) => m.userId === userId);

    if (!isOwner && !isMember) return failure(res, "Access Denied", 403);

    success(res, "Team details retrieved successfully", team);
  } catch (error) {
    console.error("Get Team Details error:", error);
    return failure(res, "Internal server error", 500);
  }
};

// Update a team (only OWNER can update)
export const updateTeam = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const { name, description, avatar } = req.body;
    const userId = req.user!.userId;

    const team = await prisma.team.findUnique({ where: { id: teamId } });
    if (!team) return failure(res, "Team not found", 404);

    if (team.ownerId !== userId)
      return failure(res, "Not allowed to update this team", 403);

    const updatedTeam = await prisma.team.update({
      where: { id: teamId },
      data: { name, description, avatar },
    });

    success(res, "Team updated successfully", updatedTeam);
  } catch (err: any) {
    console.error("Update error:", err);
    return failure(res, "Internal server error", 500);
  }
};

// Delete a team (only OWNER can delete)
export const deleteTeam = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const userId = req.user!.userId;
    const team = await prisma.team.findUnique({ where: { id: teamId } });

    if (!team) {
      return failure(res, "Team not found", 404);
    }

    // Ensure userId is compared as a string UUID
    if (team.ownerId !== String(userId)) {
      return failure(res, "Not allowed to delete this team", 403);
    }

    const deletedTeam = await prisma.team.delete({ where: { id: teamId } });

    success(res, "Team deleted successfully", deletedTeam);
  } catch (err: any) {
    console.error("Delete error:", err);
    return failure(res, "Internal server error", 500);
  }
};
