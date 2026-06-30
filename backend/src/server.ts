import dotenv from "dotenv";
dotenv.config();
import http from "http";
import { Server } from "socket.io";
import app from "./app.js";

const server = http.createServer(app);

export const io = new Server(server, {
  cors: { origin: "*" },
});

io.on("connection", (socket) => {
  console.log("Client connected:", socket.id);

  // Join personal room on auth
  socket.on("join:user", (userId: string) => {
    socket.join(`user:${userId}`);
  });

  // Join task room when viewing task detail
  socket.on("join:task", (taskId: string) => {
    socket.join(`task:${taskId}`);
  });

  socket.on("leave:task", (taskId: string) => {
    socket.leave(`task:${taskId}`);
  });

  // Join project room
  socket.on("join:project", (projectId: string) => {
    socket.join(`project:${projectId}`);
  });

  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
  });
});

app.get("/test", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Test is Working",
  });
});

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

import { prisma } from "./prisma/client.js";

const gracefulShutdown = () => {
  console.log("Received termination signal, shutting down gracefully...");
  server.close(async () => {
    console.log("Closed remaining server connections.");
    await prisma.$disconnect();
    console.log("Database disconnected cleanly. Exiting.");
    process.exit(0);
  });

  setTimeout(() => {
    console.error("Forcefully shutting down server due to timeout.");
    process.exit(1);
  }, 10000);
};

process.on("SIGTERM", gracefulShutdown);
process.on("SIGINT", gracefulShutdown);
