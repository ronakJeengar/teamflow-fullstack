import { Response } from "express";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";
import { successResponse, errorResponse } from "../utils/response.js";

// Get Members
export const getTeamMembers = async (req: AuthRequest, res: Response) => {
  try {
    const teamId = String(req.params.teamId);
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

    return successResponse(res, members, "Members fetched successfully");
  } catch (error) {
    console.error("Error fetching team members:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// Add member manually (if user already exists)
export const addMember = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const { userId, role } = req.body;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      return errorResponse(res, "User not found", 404);
    }

    const existing = await prisma.teamMember.findUnique({
      where: { teamId_userId: { teamId, userId } },
    });

    if (existing) return errorResponse(res, "User already in team", 400);

    const member = await prisma.teamMember.create({
      data: { teamId, userId, role: role || "MEMBER" },
    });

    return successResponse(res, member, "Member added successfully");
  } catch (error) {
    console.error("Error adding member:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// Update Role
export const updateMemberRole = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId, memberId } = req.params;
    const { role } = req.body;
    const currentUserId = req.user!.userId;

    const member = await prisma.teamMember.findFirst({
      where: { id: memberId, teamId },
    });

    if (!member) {
      return errorResponse(res, "Member not found", 404);
    }

    if (member.role === "OWNER") {
      return errorResponse(res, "Owner role cannot be changed", 403);
    }

    // Get current user's role on the team
    const currentUserMember = await prisma.teamMember.findUnique({
      where: { teamId_userId: { teamId, userId: currentUserId } },
    });

    if (!currentUserMember) {
      return errorResponse(res, "Access Denied", 403);
    }

    const currentUserRole = currentUserMember.role;

    // ADMINs cannot promote anyone to OWNER or transfer ownership
    if (role === "OWNER" && currentUserRole !== "OWNER") {
      return errorResponse(res, "Only owners can transfer ownership or promote to OWNER", 403);
    }

    // ADMINs cannot demote/edit peer ADMIN roles
    if (currentUserRole === "ADMIN" && member.role === "ADMIN") {
      return errorResponse(res, "Admins cannot modify peer admin roles", 403);
    }

    const updated = await prisma.teamMember.update({
      where: { id: memberId },
      data: { role },
    });

    return successResponse(res, updated, "Member role updated successfully");
  } catch (error) {
    console.error("Error updating member role:", error);
    return errorResponse(res, "Internal server error", 500);
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
      return errorResponse(res, "Member not found", 404);
    }

    if (member.role === "OWNER") {
      return errorResponse(res, "Owner cannot be removed", 403);
    }

    if (member.userId === currentUserId) {
      return errorResponse(res, "You cannot remove yourself", 400);
    }

    // Get current user's role on the team
    const currentUserMember = await prisma.teamMember.findUnique({
      where: { teamId_userId: { teamId, userId: currentUserId } },
    });

    if (!currentUserMember) {
      return errorResponse(res, "Access Denied", 403);
    }

    const currentUserRole = currentUserMember.role;

    // ADMINs cannot remove peer ADMINs
    if (currentUserRole === "ADMIN" && member.role === "ADMIN") {
      return errorResponse(res, "Admins cannot remove peer admins", 403);
    }

    await prisma.teamMember.delete({ where: { id: memberId } });

    return successResponse(res, null, "Member removed successfully");
  } catch (error) {
    console.error("Error removing member:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
