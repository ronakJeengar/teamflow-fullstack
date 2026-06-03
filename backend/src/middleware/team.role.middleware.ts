import { Response, NextFunction } from "express";
import { AuthRequest } from "./auth.middleware.js";
import { prisma } from "../prisma/client.js";
import { TeamMemberRole } from "@prisma/client";

export const requireTeamRole = (allowedRoles: TeamMemberRole[]) => {
  return async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      const userId = req.user?.userId;
      const { teamId } = req.params;

      if (!userId) {
        return res.status(401).json({
          message: "Unauthorized",
        });
      }

      if (!teamId) {
        return res.status(400).json({
          message: "Missing teamId",
        });
      }

      const member = await prisma.teamMember.findUnique({
        where: {
          teamId_userId: {
            teamId,
            userId,
          },
        },
      });

      if (!member) {
        return res.status(403).json({
          message: "Forbidden: not a team member",
        });
      }

      if (!allowedRoles.includes(member.role)) {
        return res.status(403).json({
          message: "Forbidden: insufficient role",
        });
      }

      next();
    } catch (error) {
      console.error("requireTeamRole error:", error);

      return res.status(500).json({
        message: "Internal server error",
      });
    }
  };
};
