import { Response } from "express";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { prisma } from "../prisma/client.js";
import crypto from "crypto";

// Send Invite
export const sendInvitation = async (req: AuthRequest, res: Response) => {
    const { teamId } = req.params;
    const { email, role } = req.body;
    const invitedBy = req.user!.userId;

    if (!email) return res.status(400).json({ message: "Email is required" });

    // 🔎 1️⃣ Check if user already exists in team
    const existingUser = await prisma.user.findUnique({
        where: { email }
    });

    if (existingUser) {
        const alreadyMember = await prisma.teamMember.findUnique({
            where: {
                teamId_userId: {
                    teamId,
                    userId: existingUser.id
                }
            }
        });

        if (alreadyMember) {
            return res
                .status(400)
                .json({ message: "User is already a member of this team" });
        }
    }

    // 🔎 2️⃣ Check if invitation already exists and pending
    const existingInvite = await prisma.teamInvitation.findFirst({
        where: {
            email,
            teamId,
            status: "PENDING"
        }
    });

    if (existingInvite) {
        return res.status(400).json({
            message: "An active invitation already exists for this email"
        });
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
            expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
        }
    });

    res.status(201).json({
        message: "Invitation sent",
        invite
    });
};

// Accept Invite
export const acceptInvitation = async (req: AuthRequest, res: Response) => {
    const userId = req.user!.userId;
    const { token } = req.params;

    const invite = await prisma.teamInvitation.findUnique({
        where: { token }
    });

    if (!invite) return res.status(404).json({ message: "Invalid invitation token" });

    // 1️⃣ Expired
    if (invite.expiresAt < new Date()) {
        await prisma.teamInvitation.update({
            where: { token },
            data: { status: "EXPIRED" }
        });

        return res.status(410).json({ message: "Invitation expired" });
    }

    // 2️⃣ Already handled
    if (invite.status !== "PENDING") {
        return res.status(400).json({
            message: `Invitation already ${invite.status.toLowerCase()}`
        });
    }

    // 3️⃣ If user already joined team somehow
    const alreadyMember = await prisma.teamMember.findUnique({
        where: {
            teamId_userId: {
                teamId: invite.teamId,
                userId
            }
        }
    });

    if (alreadyMember) {
        await prisma.teamInvitation.update({
            where: { token },
            data: { status: "CANCELLED" }
        });

        return res
            .status(400)
            .json({ message: "You are already registered in this team" });
    }

    // 4️⃣ Add user to team
    await prisma.teamMember.create({
        data: {
            teamId: invite.teamId,
            userId,
            role: invite.role
        }
    });

    // 5️⃣ Mark accepted
    await prisma.teamInvitation.update({
        where: { token },
        data: { status: "ACCEPTED" }
    });

    res.json({ message: "Team joined successfully" });
};

// Cancel Invite
export const cancelInvitation = async (req: AuthRequest, res: Response) => {
    const { token } = req.params;

    await prisma.teamInvitation.update({
        where: { token },
        data: { status: "CANCELLED" }
    });

    res.json({ message: "Invitation cancelled" });
};
