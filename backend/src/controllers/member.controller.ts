import { Response } from "express";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";

// Get Members
export const getTeamMembers = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;

  const members = await prisma.teamMember.findMany({
    where: { teamId },
    include: { user: true }
  });

  res.json(members);
};

// Add member manually (if user already exists)
export const addMember = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;
  const { userId, role } = req.body;

  const existing = await prisma.teamMember.findUnique({
    where: { teamId_userId: { teamId, userId } }
  });

  if (existing) return res.status(400).json({ message: "User already in team" });

  const member = await prisma.teamMember.create({
    data: { teamId, userId, role: role || "MEMBER" }
  });

  res.status(201).json(member);
};

// Update Role
export const updateMemberRole = async (req: AuthRequest, res: Response) => {
  const { memberId } = req.params;
  const { role } = req.body;

  const member = await prisma.teamMember.update({
    where: { id: memberId },
    data: { role }
  });

  res.json(member);
};

// Remove Member
export const removeMember = async (req: AuthRequest, res: Response) => {
  const { memberId } = req.params;

  await prisma.teamMember.delete({ where: { id: memberId } });

  res.json({ message: "Member removed" });
};
