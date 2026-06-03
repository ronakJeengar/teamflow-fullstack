import { Response } from "express";
import crypto from "crypto";

import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";
import { failure, success } from "../utils/response.js";

// ======================================================
// SEND INVITATION
// ======================================================

export const sendInvitation = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const { email, role } = req.body;
    const invitedBy = req.user!.userId;

    if (!email) {
      return failure(res, "Email is required", 400);
    }

    // Verify inviter belongs to team
    const inviterMembership = await prisma.teamMember.findUnique({
      where: {
        teamId_userId: {
          teamId,
          userId: invitedBy,
        },
      },
    });

    if (!inviterMembership) {
      return failure(res, "You are not a member of this team", 403);
    }

    // Optional:
    // if (!["OWNER", "ADMIN"].includes(inviterMembership.role)) {
    //   return failure(res, "Insufficient permissions", 403);
    // }

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
        return failure(res, "User is already a member of this team", 400);
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
      return failure(
        res,
        "An active invitation already exists for this email",
        400,
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

    return success(res, "Invitation sent successfully", { invite }, 201);
  } catch (error) {
    console.error("Send Invitation error:", error);
    return failure(res, "Internal server error", 500);
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
    });

    if (!invite) {
      return failure(res, "Invalid invitation token", 404);
    }

    if (invite.expiresAt < new Date()) {
      await prisma.teamInvitation.update({
        where: { token },
        data: { status: "EXPIRED" },
      });

      return failure(res, "Invitation expired", 410);
    }

    if (invite.status !== "PENDING") {
      return failure(
        res,
        `Invitation already ${invite.status.toLowerCase()}`,
        400,
      );
    }

    // IMPORTANT SECURITY CHECK
    if (invite.email.toLowerCase() !== userEmail.toLowerCase()) {
      return failure(
        res,
        "This invitation belongs to a different email address",
        403,
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
        data: { status: "CANCELLED" },
      });

      return failure(res, "You are already a member of this team", 400);
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

    return success(res, "Team joined successfully", null, 200);
  } catch (error: any) {
    console.error("Accept Invitation error:", error);

    if (error.code === "P2002") {
      return failure(res, "You are already a member of this team", 400);
    }

    return failure(res, "Internal server error", 500);
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
      return failure(res, "Invitation not found", 404);
    }

    if (invite.status !== "PENDING") {
      return failure(
        res,
        `Cannot cancel ${invite.status.toLowerCase()} invitation`,
        400,
      );
    }

    if (invite.invitedById !== userId) {
      return failure(res, "Unauthorized", 403);
    }

    await prisma.teamInvitation.update({
      where: { token },
      data: {
        status: "CANCELLED",
      },
    });

    return success(res, "Invitation cancelled successfully", null, 200);
  } catch (error) {
    console.error("Cancel Invitation error:", error);
    return failure(res, "Internal server error", 500);
  }
};

// ======================================================
// GET MY INVITATIONS
// ======================================================

export const getMyInvitations = async (req: AuthRequest, res: Response) => {
  try {
    const email = req.user!.email;

    await prisma.teamInvitation.updateMany({
      where: {
        email,
        status: "PENDING",
        expiresAt: {
          lt: new Date(),
        },
      },
      data: {
        status: "EXPIRED",
      },
    });

    const invitations = await prisma.teamInvitation.findMany({
      where: {
        email,
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

    return success(res, "Invitations fetched", { invitations }, 200);
  } catch (error) {
    console.error("Get Invitations error:", error);
    return failure(res, "Internal server error", 500);
  }
};
