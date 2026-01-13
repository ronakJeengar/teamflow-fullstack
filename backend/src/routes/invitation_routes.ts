import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import { requireTeamRole } from "../middleware/team.role.middleware.js";
import {
  acceptInvitation,
  cancelInvitation,
  sendInvitation,
} from "../controllers/invitation.controller.js";

const router = Router();
router.use(authenticate);

router.post(
  "/:teamId/invitations",
  requireTeamRole(["OWNER", "ADMIN"]),
  sendInvitation
);

router.post("/accept/:token", acceptInvitation);

router.delete(
  "/:teamId/invitations/:token",
  requireTeamRole(["OWNER", "ADMIN"]),
  cancelInvitation
);

export default router;
