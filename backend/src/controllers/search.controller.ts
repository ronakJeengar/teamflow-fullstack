import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { searchSchema } from "../utils/validation.js";

// GET /search?q=query&type=all|tasks|projects|teams&limit=10
export const search = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const validation = searchSchema.safeParse({
      q: req.query.q,
      type: req.query.type,
      limit: req.query.limit,
    });

    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { q, type, limit } = validation.data;

    const taskPromise = (type === "all" || type === "tasks")
      ? prisma.task.findMany({
          where: {
            AND: [
              {
                OR: [
                  { title: { contains: q, mode: "insensitive" } },
                  { description: { contains: q, mode: "insensitive" } },
                ],
              },
              {
                OR: [
                  { createdById: userId },
                  { assignedToId: userId },
                  {
                    project: {
                      team: {
                        members: {
                          some: { userId },
                        },
                      },
                    },
                  },
                ],
              },
            ],
          },
          take: limit,
          include: {
            project: {
              select: {
                id: true,
                name: true,
                teamId: true,
              },
            },
            assignedTo: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
          },
        })
      : Promise.resolve([]);

    const projectPromise = (type === "all" || type === "projects")
      ? prisma.project.findMany({
          where: {
            AND: [
              {
                OR: [
                  { name: { contains: q, mode: "insensitive" } },
                  { description: { contains: q, mode: "insensitive" } },
                ],
              },
              {
                team: {
                  members: {
                    some: { userId },
                  },
                },
              },
            ],
          },
          take: limit,
          include: {
            team: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        })
      : Promise.resolve([]);

    const teamPromise = (type === "all" || type === "teams")
      ? prisma.team.findMany({
          where: {
            AND: [
              {
                OR: [
                  { name: { contains: q, mode: "insensitive" } },
                  { description: { contains: q, mode: "insensitive" } },
                ],
              },
              {
                members: {
                  some: { userId },
                },
              },
            ],
          },
          take: limit,
          include: {
            _count: {
              select: {
                members: true,
                projects: true,
              },
            },
          },
        })
      : Promise.resolve([]);

    const [tasks, projects, teams] = await Promise.all([
      taskPromise,
      projectPromise,
      teamPromise,
    ]);

    return successResponse(res, { tasks, projects, teams });
  } catch (error) {
    console.error("Error performing search:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
