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

// DELETE /workspaces/:id — delete workspace (owner only)
export const deleteWorkspace = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const workspace = await prisma.workspace.findUnique({
      where: { id },
    });

    if (!workspace) {
      return errorResponse(res, "Workspace not found", 404);
    }

    if (workspace.ownerId !== userId) {
      return errorResponse(res, "Access denied. Only the workspace owner can delete it.", 403);
    }

    await prisma.workspace.delete({
      where: { id },
    });

    return successResponse(res, null, "Workspace deleted successfully");
  } catch (error) {
    console.error("Error deleting workspace:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// GET /workspaces/:id/members — list workspace members
export const getWorkspaceMembers = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const workspace = await prisma.workspace.findUnique({
      where: { id },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                avatar: true,
              },
            },
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

    return successResponse(res, workspace.members);
  } catch (error) {
    console.error("Error fetching workspace members:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// POST /workspaces/:id/members — invite/add member to workspace
export const addWorkspaceMember = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { email, role } = req.body;
    const userId = req.user!.userId;

    if (!email) {
      return errorResponse(res, "Email is required", 400);
    }

    const workspace = await prisma.workspace.findUnique({
      where: { id },
      include: {
        members: true,
      },
    });

    if (!workspace) {
      return errorResponse(res, "Workspace not found", 404);
    }

    // Only OWNER or ADMIN can invite/add members
    const myMembership = workspace.members.find((m) => m.userId === userId);
    if (workspace.ownerId !== userId && (!myMembership || myMembership.role !== "ADMIN")) {
      return errorResponse(res, "Access denied. Only owner or admin can add members.", 403);
    }

    const userToAdd = await prisma.user.findUnique({
      where: { email },
    });

    if (!userToAdd) {
      return errorResponse(res, "User with this email does not exist", 404);
    }

    const existingMember = workspace.members.find((m) => m.userId === userToAdd.id);
    if (existingMember) {
      return errorResponse(res, "User is already a member of this workspace", 400);
    }

    const newMember = await prisma.workspaceMember.create({
      data: {
        workspaceId: id,
        userId: userToAdd.id,
        role: role || "MEMBER",
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            avatar: true,
          },
        },
      },
    });

    return successResponse(res, newMember, "Member added successfully", 201);
  } catch (error) {
    console.error("Error adding workspace member:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// PATCH /workspaces/:id/members/:memberId — update workspace member role
export const updateWorkspaceMemberRole = async (req: AuthRequest, res: Response) => {
  try {
    const { id, memberId } = req.params;
    const { role } = req.body;
    const userId = req.user!.userId;

    if (!role || !["OWNER", "ADMIN", "MEMBER", "VIEWER"].includes(role.toUpperCase())) {
      return errorResponse(res, "Invalid or missing role", 400);
    }

    const workspace = await prisma.workspace.findUnique({
      where: { id },
      include: {
        members: true,
      },
    });

    if (!workspace) {
      return errorResponse(res, "Workspace not found", 404);
    }

    // Only OWNER can change roles
    if (workspace.ownerId !== userId) {
      return errorResponse(res, "Access denied. Only the owner can change roles.", 403);
    }

    const memberToUpdate = workspace.members.find((m) => m.id === memberId);
    if (!memberToUpdate) {
      return errorResponse(res, "Member not found in workspace", 404);
    }

    // Owner cannot change their own role to something else
    if (memberToUpdate.userId === userId) {
      return errorResponse(res, "Owner cannot modify their own role", 400);
    }

    const updated = await prisma.workspaceMember.update({
      where: { id: memberId },
      data: { role: role.toUpperCase() },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            avatar: true,
          },
        },
      },
    });

    return successResponse(res, updated, "Role updated successfully");
  } catch (error) {
    console.error("Error updating workspace member role:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};

// DELETE /workspaces/:id/members/:memberId — remove workspace member
export const removeWorkspaceMember = async (req: AuthRequest, res: Response) => {
  try {
    const { id, memberId } = req.params;
    const userId = req.user!.userId;

    const workspace = await prisma.workspace.findUnique({
      where: { id },
      include: {
        members: true,
      },
    });

    if (!workspace) {
      return errorResponse(res, "Workspace not found", 404);
    }

    const myMembership = workspace.members.find((m) => m.userId === userId);
    const memberToRemove = workspace.members.find((m) => m.id === memberId);

    if (!memberToRemove) {
      return errorResponse(res, "Member not found in workspace", 404);
    }

    // Owner cannot remove self
    if (memberToRemove.userId === workspace.ownerId) {
      return errorResponse(res, "Owner cannot be removed from workspace", 400);
    }

    // Only OWNER or ADMIN can remove members
    const isOwner = workspace.ownerId === userId;
    const isAdmin = myMembership?.role === "ADMIN";

    if (!isOwner && !isAdmin) {
      return errorResponse(res, "Access denied. Insufficient permissions.", 403);
    }

    if (isAdmin && !isOwner && ["ADMIN", "OWNER"].includes(memberToRemove.role)) {
      return errorResponse(res, "Access denied. Admins cannot remove other Admins or Owners.", 403);
    }

    await prisma.workspaceMember.delete({
      where: { id: memberId },
    });

    return successResponse(res, null, "Member removed successfully");
  } catch (error) {
    console.error("Error removing workspace member:", error);
    return errorResponse(res, "Internal server error", 500);
  }
};
