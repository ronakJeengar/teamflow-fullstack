import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";
import { createWorkspaceSchema } from "../utils/validation.js";
import jwt from "jsonwebtoken";

// GET /workspaces — list workspaces for current user
export const getWorkspaces = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;

    const workspaces = await prisma.workspace.findMany({
      where: {
        OR: [
          { ownerId: userId },
          {
            members: {
              some: { userId },
            },
          },
        ],
      },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        _count: {
          select: {
            members: true,
            teams: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return successResponse(res, workspaces);
  } catch (error) {
    console.error("Error fetching workspaces:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// POST /workspaces — create workspace { name, color }
export const createWorkspace = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user!.userId;
    const validation = createWorkspaceSchema.safeParse(req.body);

    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { name, color } = validation.data;

    // Generate unique slug
    let slug = name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)+/g, "");
    
    if (!slug) {
      slug = "workspace";
    }

    const count = await prisma.workspace.count({ where: { slug } });
    if (count > 0) {
      slug = `${slug}-${Math.random().toString(36).substring(2, 7)}`;
    }

    const workspace = await prisma.$transaction(async (tx) => {
      const ws = await tx.workspace.create({
        data: {
          name,
          slug,
          color: color || "#7C5CFF",
          ownerId: userId,
        },
      });

      await tx.workspaceMember.create({
        data: {
          workspaceId: ws.id,
          userId,
          role: "OWNER",
        },
      });

      return ws;
    });

    return successResponse(res, workspace, "Workspace created successfully", 201);
  } catch (error) {
    console.error("Error creating workspace:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /workspaces/:id — workspace detail with teams
export const getWorkspace = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const workspace = await prisma.workspace.findUnique({
      where: { id },
      include: {
        teams: {
          include: {
            _count: {
              select: {
                members: true,
                projects: true,
              },
            },
          },
        },
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                avatar: true,
              },
            },
          },
        },
        owner: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    if (!workspace) {
      return errorResponse(res, "Workspace not found", 404);
    }

    const isMember =
      workspace.ownerId === userId || workspace.members.some((m) => m.userId === userId);

    if (!isMember) {
      return errorResponse(res, "Access denied. Not a workspace member.", 403);
    }

    return successResponse(res, workspace);
  } catch (error) {
    console.error("Error fetching workspace details:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// PATCH /workspaces/:id — update workspace (owner only)
export const updateWorkspace = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const validation = createWorkspaceSchema.safeParse(req.body);
    if (!validation.success) {
      return errorResponse(res, "Validation error", 400, validation.error.format());
    }

    const { name, color } = validation.data;

    const workspace = await prisma.workspace.findUnique({
      where: { id },
    });

    if (!workspace) {
      return errorResponse(res, "Workspace not found", 404);
    }

    if (workspace.ownerId !== userId) {
      return errorResponse(res, "Access denied. Only the workspace owner can update it.", 403);
    }

    // Generate new slug if name is changing
    let slug = workspace.slug;
    if (name && name !== workspace.name) {
      slug = name
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/(^-|-$)+/g, "");
      
      if (!slug) {
        slug = "workspace";
      }

      const count = await prisma.workspace.count({
        where: { slug, id: { not: id } },
      });
      if (count > 0) {
        slug = `${slug}-${Math.random().toString(36).substring(2, 7)}`;
      }
    }

    const updatedWorkspace = await prisma.workspace.update({
      where: { id },
      data: {
        name,
        color,
        slug,
      },
    });

    return successResponse(res, updatedWorkspace, "Workspace updated successfully");
  } catch (error) {
    console.error("Error updating workspace:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// POST /workspaces/:id/switch — set active workspace in session/JWT
export const switchWorkspace = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const workspace = await prisma.workspace.findUnique({
      where: { id },
      include: {
        members: {
          where: { userId },
        },
      },
    });

    if (!workspace) {
      return errorResponse(res, "Workspace not found", 404);
    }

    const isMember =
      workspace.ownerId === userId || workspace.members.length > 0;

    if (!isMember) {
      return errorResponse(res, "Access denied. Not a workspace member.", 403);
    }

    // Sign new access token with activeWorkspaceId
    const accessToken = jwt.sign(
      {
        userId,
        email: req.user!.email,
        role: req.user!.role,
        activeWorkspaceId: id,
      },
      process.env.JWT_ACCESS_SECRET!,
      { expiresIn: "15m" }
    );

    res.cookie("accessToken", accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 15 * 60 * 1000,
    });

    return successResponse(res, { activeWorkspaceId: id }, "Active workspace switched successfully");
  } catch (error) {
    console.error("Error switching workspace:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
