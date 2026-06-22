import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  createTask,
  deleteTask,
  getTasks,
  updateTask,
  getMyTasks,
  getTaskById,
} from "../controllers/task.controller.js";

const router = Router();

router.use(authenticate);

// Concrete routes first
router.get("/my", getMyTasks);
router.get("/project/:projectId", getTasks);
router.post("/create", createTask); // Backward compatibility

// General REST routes
router.post("/", createTask);
router.get("/:id", getTaskById);
router.patch("/:id", updateTask);
router.delete("/:id", deleteTask);

export default router;
