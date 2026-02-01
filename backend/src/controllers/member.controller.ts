import { Response } from "express";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";
import { tr } from "zod/locales";
import { failure, success } from "../utils/response.js";

// Get Members
export const getTeamMembers = async (req: AuthRequest, res: Response) => {
  try {
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

    return success(res, "Members fetched successfully", members);
  } catch (error) {
    console.error("Error fetching team members:", error);
    return failure(res, "Internal server error", 500);
  }
};

// Add member manually (if user already exists)
export const addMember = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const { userId, role } = req.body;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      return failure(res, "User not found", 404);
    }

    const existing = await prisma.teamMember.findUnique({
      where: { teamId_userId: { teamId, userId } },
    });

    if (existing)
      return failure(res, "User already in team", 400);

    const member = await prisma.teamMember.create({
      data: { teamId, userId, role: role || "MEMBER" },
    });

    return success(res, "Member added successfully", member);
  } catch (error) {
    console.error("Error adding member:", error);
    return failure(res, "Internal server error", 500);
  }
};

// Update Role
export const updateMemberRole = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId, memberId } = req.params;
    const { role } = req.body;

    const member = await prisma.teamMember.findFirst({
      where: { id: memberId, teamId },
    });

    if (!member) {
      return failure(res, "Member not found", 404);
    }

    if (member.role === "OWNER") {
      return failure(res, "Owner role cannot be changed", 403);
    }

    const updated = await prisma.teamMember.update({
      where: { id: memberId },
      data: { role },
    });

    return success(res, "Member role updated successfully", updated);
  } catch (error) {
    console.error("Error updating member role:", error);
    return failure(res, "Internal server error", 500);
  }
};

// Remove Member
export const removeMember = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId, memberId } = req.params;
    const currentUserId = req.user!.userId;

    const member = await prisma.teamMember.findFirst({
      where: { id: memberId, teamId },
    });

    if (!member) {
      return failure(res, "Member not found", 404);
    }

    if (member.role === "OWNER") {
      return failure(res, "Owner cannot be removed", 403);
    }

    if (member.userId === currentUserId) {
      return failure(res, "You cannot remove yourself", 400);
    }

    await prisma.teamMember.delete({ where: { id: memberId } });

    return success(res, "Member removed successfully", null);
  } catch (error) {
    console.error("Error removing member:", error);
    return failure(res, "Internal server error", 500);
  }
};
