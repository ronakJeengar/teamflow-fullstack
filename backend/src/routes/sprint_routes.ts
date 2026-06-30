import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getSprints,
  createSprint,
  getSprintById,
  updateSprint,
  deleteSprint,
  getSprintTasks,
  assignTasksToSprint,
  removeTaskFromSprint,
  startSprint,
  completeSprint,
  cancelSprint,
  getSprintStats,
  getSprintBurndown,
  getSprintVelocity
} from "../controllers/sprint.controller.js";

const router = Router();

router.use(authenticate);

// Workspace/Team scope sprints
router.get("/sprints", getSprints);
router.post("/sprints", createSprint);

// Individual sprints
router.get("/sprints/:id", getSprintById);
router.patch("/sprints/:id", updateSprint);
router.delete("/sprints/:id", deleteSprint);

// Tasks of sprint
router.get("/sprints/:id/tasks", getSprintTasks);

// Task assignment
router.post("/sprints/:id/tasks", assignTasksToSprint);
router.delete("/sprints/:id/tasks/:taskId", removeTaskFromSprint);

// Lifecycle
router.post("/sprints/:id/start", startSprint);
router.post("/sprints/:id/complete", completeSprint);
router.post("/sprints/:id/cancel", cancelSprint);

// Metrics
router.get("/sprints/:id/stats", getSprintStats);
router.get("/sprints/:id/burndown", getSprintBurndown);
router.get("/sprints/:id/velocity", getSprintVelocity);

export default router;
