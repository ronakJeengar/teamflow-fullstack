import { Response } from "express";
import crypto from "crypto";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { createNotification } from "./notification.controller.js";

// ======================================================
// SEND INVITATION
// ======================================================

export const sendInvitation = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const { email, role } = req.body;
    const invitedBy = req.user!.userId;

    if (!email) {
      return errorResponse(res, "Email is required", 400);
    }

    const team = await prisma.team.findUnique({
      where: { id: teamId },
    });

    if (!team) {
      return errorResponse(res, "Team not found", 404);
    }

    if (email.toLowerCase() === req.user!.email.toLowerCase()) {
      return errorResponse(res, "You cannot invite yourself", 400);
    }

    const allowedRoles = ["ADMIN", "MEMBER", "VIEWER"];

    if (role && !allowedRoles.includes(role)) {
      return errorResponse(res, "Invalid role", 400);
    }

    const inviterMembership = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId,
          userId: invitedBy,
        },
      },
    });

    if (!inviterMembership) {
      return errorResponse(res, "You are not a member of this team", 403);
    }

    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      const alreadyMember = await prisma.teamMember.findUnique({
        where: {
          teamId_userId: {
            teamId,
            userId: existingUser.id,
          },
        },
      });

      if (alreadyMember) {
        return errorResponse(res, "User is already a member of this team", 400);
      }
    }

    const existingInvite = await prisma.teamInvitation.findFirst({
      where: {
        teamId,
        email,
        status: "PENDING",
      },
    });

    if (existingInvite) {
      return errorResponse(
        res,
        "An active invitation already exists for this email",
        400
      );
    }

    const token = crypto.randomBytes(32).toString("hex");

    const invite = await prisma.teamInvitation.create({
      data: {
        teamId,
        email,
        role: role || "MEMBER",
        token,
        invitedById: invitedBy,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    // Notify the user if they already have an account in the system
    if (existingUser) {
      await createNotification({
        userId: existingUser.id,
        senderId: invitedBy,
        type: "TEAM_INVITED",
        title: "Team Invitation",
        body: `You have been invited to join the team "${team.name}"`,
        teamId,
      });
    }

    return successResponse(res, invite, "Invitation sent successfully", 201);
  } catch (error) {
    console.error("Send Invitation error:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// ======================================================
// ACCEPT INVITATION
// ======================================================

export const acceptInvitation = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const userEmail = req.user!.email;
    const { token } = req.params;

    const invite = await prisma.teamInvitation.findUnique({
      where: { token },
      include: {
        team: true,
      },
    });

    if (!invite) {
      return errorResponse(res, "Invalid invitation token", 404);
    }

    if (invite.expiresAt < new Date()) {
      await prisma.teamInvitation.update({
        where: { token },
        data: {
          status: "EXPIRED",
        },
      });

      return errorResponse(res, "Invitation expired", 410);
    }

    if (invite.status !== "PENDING") {
      return errorResponse(
        res,
        `Invitation already ${invite.status.toLowerCase()}`,
        400
      );
    }

    if (invite.email.toLowerCase() !== userEmail.toLowerCase()) {
      return errorResponse(
        res,
        "This invitation belongs to a different email address",
        403
      );
    }

    const alreadyMember = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId: invite.teamId,
          userId,
        },
      },
    });

    if (alreadyMember) {
      await prisma.teamInvitation.update({
        where: { token },
        data: {
          status: "CANCELLED",
        },
      });

      return errorResponse(res, "You are already a member of this team", 400);
    }

    await prisma.$transaction(async (tx) => {
      await tx.teamMember.create({
        data: {
          teamId: invite.teamId,
          userId,
          role: invite.role,
        },
      });

      await tx.teamInvitation.update({
        where: { token },
        data: {
          status: "ACCEPTED",
        },
      });
    });

    return successResponse(res, null, "Team joined successfully", 200);
  } catch (error: any) {
    console.error("Accept Invitation error:", error);

    if (error.code === "P2002") {
      return errorResponse(res, "You are already a member of this team", 400);
    }

    return errorResponse(res, "Internal server error", 500);
  }
};

// ======================================================
// CANCEL INVITATION
// ======================================================

export const cancelInvitation = async (req: AuthRequest, res: Response) => {
  try {
    const { token } = req.params;
    const userId = req.user!.userId;

    const invite = await prisma.teamInvitation.findUnique({
      where: { token },
    });

    if (!invite) {
      return errorResponse(res, "Invitation not found", 404);
    }

    if (invite.status !== "PENDING") {
      return errorResponse(
        res,
        `Cannot cancel ${invite.status.toLowerCase()} invitation`,
        400
      );
    }

    const member = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId: invite.teamId,
          userId,
        },
      },
    });

    if (!member || !["OWNER", "ADMIN"].includes(member.role)) {
      return errorResponse(res, "Unauthorized", 403);
    }

    await prisma.teamInvitation.update({
      where: { token },
      data: {
        status: "CANCELLED",
      },
    });

    return successResponse(res, null, "Invitation cancelled successfully", 200);
  } catch (error) {
    console.error("Cancel Invitation error:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// ======================================================
// GET MY INVITATIONS
// ======================================================

export const getMyInvitations = async (req: AuthRequest, res: Response) => {
  try {
    const email = req.user!.email;

    const invitations = await prisma.teamInvitation.findMany({
      where: {
        email,
        status: "PENDING",
        expiresAt: {
          gte: new Date(),
        },
      },
      include: {
        team: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return successResponse(res, invitations, "Invitations fetched successfully");
  } catch (error) {
    console.error("Get Invitations error:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// ======================================================
// GET TEAM INVITATIONS
// ======================================================

export const getTeamInvitations = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;

    const invitations = await prisma.teamInvitation.findMany({
      where: {
        teamId,
        status: "PENDING",
        expiresAt: {
          gte: new Date(),
        },
      },
      include: {
        invitedBy: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
      orderBy: {
        createdAt: "desc",
      },
    });

    return successResponse(res, invitations, "Team invitations fetched successfully");
  } catch (error) {
    console.error("Get Team Invitations error:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
