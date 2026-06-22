import { Router } from "express";
import {
  register,
  login,
  refresh,
  getCurrentUser,
  logout,
  getMyMemberships,
  updateProfile,
} from "../controllers/auth.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.post("/refresh", refresh);
router.get("/me", authenticate, getCurrentUser);
router.patch("/me", authenticate, updateProfile);
router.get("/memberships", authenticate, getMyMemberships);
router.get("/logout", authenticate, logout);

export default router;
