import { Response } from "express";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";
import crypto from "crypto";
import { failure, success } from "../utils/response.js";

// Send Invite
export const sendInvitation = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const { email, role } = req.body;
    const invitedBy = req.user!.userId;

    if (!email) {
      return failure(res, "Email is required", 400);
    }

    // 🔎 1️⃣ Check if user already exists in team
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

    // 🔎 2️⃣ Check if invitation already exists and pending
    const existingInvite = await prisma.teamInvitation.findFirst({
      where: {
        email,
        teamId,
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

    // 3️⃣ Create secure token
    const token = crypto.randomBytes(32).toString("hex");

    const invite = await prisma.teamInvitation.create({
      data: {
        teamId,
        email,
        role: role || "MEMBER",
        token,
        invitedBy,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      },
    });

    return success(res, "Invitation sent successfully", { invite }, 201);
  } catch (error) {
    console.error("Send Invitation error:", error);
    return failure(res, "Internal server error", 500);
  }
};

// Accept Invite
export const acceptInvitation = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const { token } = req.params;

    const invite = await prisma.teamInvitation.findUnique({
      where: { token },
    });

    if (!invite) return failure(res, "Invalid invitation token", 404);

    // 1️⃣ Expired
    if (invite.expiresAt < new Date()) {
      await prisma.teamInvitation.update({
        where: { token },
        data: { status: "EXPIRED" },
      });

      return failure(res, "Invitation expired", 410);
    }

    // 2️⃣ Already handled
    if (invite.status !== "PENDING") {
      return failure(
        res,
        `Invitation already ${invite.status.toLowerCase()}`,
        400,
      );
    }

    // 3️⃣ If user already joined team somehow
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

      return failure(res, "You are already registered in this team", 400);
    }

    // 4️⃣ Add user to team
    await prisma.teamMember.create({
      data: {
        teamId: invite.teamId,
        userId,
        role: invite.role,
      },
    });

    // 5️⃣ Mark accepted
    await prisma.teamInvitation.update({
      where: { token },
      data: { status: "ACCEPTED" },
    });

    return success(res, "Team joined successfully", null, 200);
  } catch (error) {
    console.error("Accept Invitation error:", error);
    return failure(res, "Internal server error", 500);
  }
};

// Cancel Invite
export const cancelInvitation = async (req: AuthRequest, res: Response) => {
  try {
    const { token } = req.params;

    await prisma.teamInvitation.update({
      where: { token },
      data: { status: "CANCELLED" },
    });
    return success(res, "Invitation cancelled successfully", null, 200);
  } catch (error) {
    console.error("Cancel Invitation error:", error);
    return failure(res, "Internal server error", 500);
  }
};
