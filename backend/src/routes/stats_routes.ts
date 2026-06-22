import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getDashboardStats,
  getProjectStats,
} from "../controllers/stats.controller.js";

const router = Router();

router.use(authenticate);

router.get("/dashboard", getDashboardStats);
router.get("/project/:projectId", getProjectStats);

export default router;
