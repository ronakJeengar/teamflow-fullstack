import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getWorkspaces,
  createWorkspace,
  getWorkspace,
  updateWorkspace,
  switchWorkspace,
  deleteWorkspace,
  getWorkspaceMembers,
  addWorkspaceMember,
  updateWorkspaceMemberRole,
  removeWorkspaceMember,
} from "../controllers/workspace.controller.js";

const router = Router();

router.use(authenticate);

router.get("/", getWorkspaces);
router.post("/", createWorkspace);
router.get("/:id", getWorkspace);
router.patch("/:id", updateWorkspace);
router.delete("/:id", deleteWorkspace);
router.post("/:id/switch", switchWorkspace);

// Member management
router.get("/:id/members", getWorkspaceMembers);
router.post("/:id/members", addWorkspaceMember);
router.patch("/:id/members/:memberId", updateWorkspaceMemberRole);
router.delete("/:id/members/:memberId", removeWorkspaceMember);

export default router;
