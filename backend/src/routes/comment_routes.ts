import { Router } from "express";
import { authenticate } from "../middleware/auth.middleware.js";
import {
  getComments,
  createComment,
  updateComment,
  deleteComment,
} from "../controllers/comment.controller.js";

const router = Router();

router.use(authenticate);

router.get("/tasks/:taskId/comments", getComments);
router.post("/tasks/:taskId/comments", createComment);
router.patch("/comments/:commentId", updateComment);
router.patch("/tasks/:taskId/comments/:commentId", updateComment);
router.delete("/comments/:commentId", deleteComment);
router.delete("/tasks/:taskId/comments/:commentId", deleteComment);

export default router;
