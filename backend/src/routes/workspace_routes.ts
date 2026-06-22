import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getWorkspaces,
  createWorkspace,
  getWorkspace,
  updateWorkspace,
  switchWorkspace,
} from "../controllers/workspace.controller.js";

const router = Router();

router.use(authenticate);

router.get("/", getWorkspaces);
router.post("/", createWorkspace);
router.get("/:id", getWorkspace);
router.patch("/:id", updateWorkspace);
router.post("/:id/switch", switchWorkspace);

export default router;
