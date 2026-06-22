import "./config.js";
import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth_routes.js";
import projectRoutes from "./routes/project_routes.js";
import taskRoutes from "./routes/task_routes.js";
import teamRoutes from "./routes/team_routes.js";
import memberRoutes from "./routes/member_routes.js";
import invitationRoutes from "./routes/invitation_routes.js";
import notificationRoutes from "./routes/notification_routes.js";
import commentRoutes from "./routes/comment_routes.js";
import searchRoutes from "./routes/search_routes.js";
import statsRoutes from "./routes/stats_routes.js";
import workspaceRoutes from "./routes/workspace_routes.js";
import activityRoutes from "./routes/activity_routes.js";
import { errorHandler } from "./middleware/error.middleware.js";
import cookieParser from "cookie-parser";

const app = express();

app.use(
  cors({
    origin: "http://localhost:5173",
    credentials: true,
  }),
);

app.use(cookieParser());
app.use(express.json());

// Auth
app.use("/api/v1/auth", authRoutes);
app.use("/api/auth", authRoutes);

// Teams
app.use("/api/v1/teams", teamRoutes);
app.use("/api/teams", teamRoutes);

// Projects
app.use("/api/v1/projects", projectRoutes);
// app.use("/api/projects", projectRoutes);

// Tasks
app.use("/api/v1/tasks", taskRoutes);
app.use("/api/tasks", taskRoutes);

// Members
app.use("/api/v1/teams/:teamId/members", memberRoutes);
app.use("/api/teams/:teamId/members", memberRoutes);

// Invitations
app.use("/api/v1/invitations", invitationRoutes);
app.use("/api/invitations", invitationRoutes);

// Notifications
app.use("/api/notifications", notificationRoutes);

// Comments (/api/tasks/:taskId/comments)
app.use("/api", commentRoutes);

// Search
app.use("/api/search", searchRoutes);

// Stats
app.use("/api/stats", statsRoutes);

// Workspaces
app.use("/api/workspaces", workspaceRoutes);

// Activities
app.use("/api/activities", activityRoutes);

app.use(errorHandler);

export default app;
