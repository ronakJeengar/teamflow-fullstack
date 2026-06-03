import { Router } from "express";
import { TeamMemberRole } from "@prisma/client";

import { authenticate } from "../middleware/auth.middleware.js";
import { requireTeamRole } from "../middleware/team.role.middleware.js";

import {
  acceptInvitation,
  cancelInvitation,
  sendInvitation,
  getMyInvitations,
} from "../controllers/invitation.controller.js";

const router = Router();

router.use(authenticate);

// Get current user's invitations
router.get("/my", getMyInvitations);

// Send invitation
router.post(
  "/:teamId/invitations",
  requireTeamRole([TeamMemberRole.OWNER, TeamMemberRole.ADMIN]),
  sendInvitation,
);

// Accept invitation
router.post("/accept/:token", acceptInvitation);

// Cancel invitation
router.delete(
  "/:teamId/invitations/:token",
  requireTeamRole([TeamMemberRole.OWNER, TeamMemberRole.ADMIN]),
  cancelInvitation,
);

export default router;
