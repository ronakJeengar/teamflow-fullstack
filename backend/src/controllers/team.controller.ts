import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";

export type TeamMemberRole = "OWNER" | "ADMIN" | "MEMBER" | "VIEWER";

// Create a new team
export const createTeam = async (req: AuthRequest, res: Response) => {
  const { name, description, avatar } = req.body;
  const userId = req.user!.userId;

  if (!name) return res.status(400).json({ message: "Team name is required" });

  const team = await prisma.team.create({
    data: {
      name,
      description,
      avatar,
      ownerId: userId,
      members: {
        create: {
          userId, role: "OWNER" as TeamMemberRole,
        }
      },
    },
    include: { members: true },
  });

  res.status(201).json(team);
};

// Get all teams where the user is a member
export const getMyTeams = async (req: AuthRequest, res: Response) => {
  const userId = req.user!.userId;

  const memberships = await prisma.teamMember.findMany({
    where: { userId },
    include: { team: true },
  });

  const teams = memberships.map((m) => m.team);
  res.json(teams);
};

// Get detailed info of a specific team
export const getTeamDetails = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;

  const team = await prisma.team.findUnique({
    where: { id: teamId },
    include: {
      members: { include: { user: true } },
      projects: true,
      invitations: true,
    },
  });

  if (!team) return res.status(404).json({ message: "Team not found" });

  res.json(team);
};

// Update a team (only OWNER can update)
export const updateTeam = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;
  const { name, description, avatar } = req.body;
  const userId = req.user!.userId;

  const team = await prisma.team.findUnique({ where: { id: teamId } });
  if (!team) return res.status(404).json({ message: "Team not found" });

  if (team.ownerId !== userId)
    return res.status(403).json({ message: "Not allowed to update this team" });

  const updatedTeam = await prisma.team.update({
    where: { id: teamId },
    data: { name, description, avatar },
  });

  res.json(updatedTeam);
};

// Delete a team (only OWNER can delete)
export const deleteTeam = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;
  const userId = req.user!.userId;

  const team = await prisma.team.findUnique({ where: { id: teamId } });
  if (!team) return res.status(404).json({ message: "Team not found" });

  if (team.ownerId !== userId)
    return res.status(403).json({ message: "Not allowed to delete this team" });

  await prisma.team.delete({ where: { id: teamId } });

  res.status(200).json({ message: "Team deleted successfully" });
};
