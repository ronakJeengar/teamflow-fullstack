import './config.js';
import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth_routes.js";
import projectRoutes from "./routes/project_routes.js";
import taskRoutes from "./routes/task_routes.js";
import { errorHandler } from './middleware/error.middleware.js';
import cookieParser from 'cookie-parser';

const app = express();

app.use(
    cors({
        origin: "http://localhost:5173",
        credentials: true,
    })
);

app.use(cookieParser());
app.use(express.json());

app.use("/api/v1/auth", authRoutes);
app.use("/api/v1/projects", projectRoutes);
app.use("/api/v1/tasks", taskRoutes);

app.use(errorHandler);

export default app;
