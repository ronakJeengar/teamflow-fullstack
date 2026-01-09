import { Response } from "express";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";

// Get Members
export const getTeamMembers = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;

  const members = await prisma.teamMember.findMany({
    where: { teamId },
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
  });

  res.json(members);
};

// Add member manually (if user already exists)
export const addMember = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;
  const { userId, role } = req.body;

  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) {
    return res.status(404).json({ message: "User not found" });
  }

  const existing = await prisma.teamMember.findUnique({
    where: { teamId_userId: { teamId, userId } },
  });

  if (existing)
    return res.status(400).json({ message: "User already in team" });

  const member = await prisma.teamMember.create({
    data: { teamId, userId, role: role || "MEMBER" },
  });

  res.status(201).json(member);
};

// Update Role
export const updateMemberRole = async (req: AuthRequest, res: Response) => {
  const { teamId, memberId } = req.params;
  const { role } = req.body;

  const member = await prisma.teamMember.findFirst({
    where: { id: memberId, teamId },
  });

  if (!member) {
    return res.status(404).json({ message: "Member not found" });
  }

  if (member.role === "OWNER") {
    return res.status(403).json({ message: "Owner role cannot be changed" });
  }

  const updated = await prisma.teamMember.update({
    where: { id: memberId },
    data: { role },
  });

  res.json(updated);
};

// Remove Member
export const removeMember = async (req: AuthRequest, res: Response) => {
  const { teamId, memberId } = req.params;
  const currentUserId = req.user!.userId;

  const member = await prisma.teamMember.findFirst({
    where: { id: memberId, teamId },
  });

  if (!member) {
    return res.status(404).json({ message: "Member not found" });
  }

  if (member.role === "OWNER") {
    return res.status(403).json({ message: "Owner cannot be removed" });
  }

  if (member.userId === currentUserId) {
    return res.status(400).json({ message: "You cannot remove yourself" });
  }

  await prisma.teamMember.delete({ where: { id: memberId } });

  res.json({ message: "Member removed" });
};
