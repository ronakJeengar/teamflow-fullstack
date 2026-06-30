import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getTaskActivities,
  getProjectActivities,
  getWorkspaceActivities,
  getTeamActivities,
} from "../controllers/activity.controller.js";

const router = Router();

router.use(authenticate);

router.get("/tasks/:taskId", getTaskActivities);
router.get("/projects/:projectId", getProjectActivities);
router.get("/workspaces/:workspaceId", getWorkspaceActivities);
router.get("/teams/:teamId", getTeamActivities);

export default router;
