import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getTaskActivities,
  getProjectActivities,
} from "../controllers/activity.controller.js";

const router = Router();

router.use(authenticate);

router.get("/tasks/:taskId", getTaskActivities);
router.get("/projects/:projectId", getProjectActivities);

export default router;
