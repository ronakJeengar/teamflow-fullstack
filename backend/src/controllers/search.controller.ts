import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { searchSchema } from "../utils/validation.js";

// GET /search?q=query&type=all|tasks|projects|teams|sprints|comments|workspaces&limit=10&priority=HIGH&assigneeId=xxx&status=TODO&dueDate=yyyy-mm-dd
export const search = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const activeWorkspaceId = req.user!.activeWorkspaceId;

    const validation = searchSchema.safeParse({
      q: req.query.q,
      type: req.query.type,
      limit: req.query.limit,
    });

    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { q, type, limit } = validation.data;

    // Filters for tasks and comments
    const priority = req.query.priority as string;
    const assigneeId = req.query.assigneeId as string;
    const status = req.query.status as string;
    const dueDate = req.query.dueDate as string;

    const taskWhere: any = {
      project: {
        team: {
          workspaceId: activeWorkspaceId,
        },
      },
      OR: [
        { title: { contains: q, mode: "insensitive" } },
        { description: { contains: q, mode: "insensitive" } },
      ],
    };

    if (priority) taskWhere.priority = priority;
    if (assigneeId) taskWhere.assignedToId = assigneeId;
    if (status) taskWhere.status = status;
    if (dueDate) {
      const parsedDate = new Date(dueDate);
      if (!isNaN(parsedDate.getTime())) {
        const startOfDay = new Date(parsedDate.setHours(0, 0, 0, 0));
        const endOfDay = new Date(parsedDate.setHours(23, 59, 59, 999));
        taskWhere.dueDate = {
          gte: startOfDay,
          lte: endOfDay,
        };
      }
    }

    const taskPromise = (type === "all" || type === "tasks")
      ? prisma.task.findMany({
          where: taskWhere,
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

    const commentWhere: any = {
      task: {
        project: {
          team: {
            workspaceId: activeWorkspaceId,
          },
        },
      },
      message: { contains: q, mode: "insensitive" },
    };

    if (priority) commentWhere.task.priority = priority;
    if (assigneeId) commentWhere.task.assignedToId = assigneeId;
    if (status) commentWhere.task.status = status;
    if (dueDate) {
      const parsedDate = new Date(dueDate);
      if (!isNaN(parsedDate.getTime())) {
        const startOfDay = new Date(parsedDate.setHours(0, 0, 0, 0));
        const endOfDay = new Date(parsedDate.setHours(23, 59, 59, 999));
        commentWhere.task.dueDate = {
          gte: startOfDay,
          lte: endOfDay,
        };
      }
    }

    const commentPromise = (type === "all" || type === "comments")
      ? prisma.comment.findMany({
          where: commentWhere,
          take: limit,
          include: {
            author: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
            task: {
              select: {
                id: true,
                title: true,
                projectId: true,
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
                  workspaceId: activeWorkspaceId,
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
                workspaceId: activeWorkspaceId,
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

    const sprintPromise = (type === "all" || type === "sprints")
      ? prisma.sprint.findMany({
          where: {
            AND: [
              {
                OR: [
                  { name: { contains: q, mode: "insensitive" } },
                  { goal: { contains: q, mode: "insensitive" } },
                ],
              },
              {
                workspaceId: activeWorkspaceId,
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

    const workspacePromise = (type === "all" || type === "workspaces")
      ? prisma.workspace.findMany({
          where: {
            AND: [
              { name: { contains: q, mode: "insensitive" } },
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
                teams: true,
              },
            },
          },
        })
      : Promise.resolve([]);

    const [tasks, comments, projects, teams, sprints, workspaces] = await Promise.all([
      taskPromise,
      commentPromise,
      projectPromise,
      teamPromise,
      sprintPromise,
      workspacePromise,
    ]);

    return successResponse(res, {
      tasks,
      comments,
      projects,
      teams,
      sprints,
      workspaces,
    });
  } catch (error) {
    console.error("Error performing search:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
