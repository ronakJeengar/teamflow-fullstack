import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getTeamMembers,
  addMember,
  updateMemberRole,
  removeMember,
} from "../controllers/member.controller.js";
import { requireTeamRole } from "../middleware/team.role.middleware.js";

const router = Router();
router.use(authenticate);

router.get(
  "/",
  requireTeamRole(["OWNER", "ADMIN", "MEMBER", "VIEWER"]),
  getTeamMembers
);

router.post("/", requireTeamRole(["OWNER", "ADMIN"]), addMember);

router.patch("/:memberId", requireTeamRole(["OWNER"]), updateMemberRole);

router.delete("/:memberId", requireTeamRole(["OWNER"]), removeMember);

export default router;
