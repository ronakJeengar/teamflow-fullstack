import { Router, Request, Response } from "express";
import { prisma } from "../prisma/client.js";

const router = Router();
const startupTime = new Date();

// GET /api/v1/health
router.get("/health", (_: Request, res: Response) => {
  return res.status(200).json({
    status: "UP",
    uptime: `${Math.floor((new Date().getTime() - startupTime.getTime()) / 1000)}s`,
    timestamp: new Date().toISOString(),
  });
});

// GET /api/v1/ready
router.get("/ready", async (_: Request, res: Response) => {
  try {
    // Check Database connection
    await prisma.$queryRaw`SELECT 1`;
    return res.status(200).json({
      status: "READY",
      checks: {
        database: "UP",
      },
    });
  } catch (error) {
    return res.status(503).json({
      status: "DOWN",
      checks: {
        database: "DOWN",
      },
      error: error instanceof Error ? error.message : String(error),
    });
  }
});

// GET /api/v1/version
router.get("/version", (_: Request, res: Response) => {
  return res.status(200).json({
    version: "1.0.0-rc1",
    build: "release-candidate",
    nodeVersion: process.version,
    platform: process.platform,
  });
});

export default router;
