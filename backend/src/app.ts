import './config.js';

import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth_routes.js";
import projectRoutes from "./routes/project_routes.js"

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/v1/auth", authRoutes);
app.use('/api/v1/projects', projectRoutes);


export default app;