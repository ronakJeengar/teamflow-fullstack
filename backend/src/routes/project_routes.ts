import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  createProject,
  deleteProject,
  getProjects,
  updateProject,
  getProjectById,
} from "../controllers/project.controller.js";

const router = Router();

router.use(authenticate);

// Standard projects routes
// router.get("/", getProjects);
// router.post("/", createProject);
router.get("/:teamId/:id", getProjectById);
// router.patch("/:id", updateProject);
// router.delete("/:id", deleteProject);

// Backward compatibility project routes (team-based)
router.post("/:teamId/create", createProject);
router.get("/:teamId", getProjects);
router.patch("/:teamId/:id", updateProject);
router.delete("/:teamId/:id", deleteProject);

export default router;
