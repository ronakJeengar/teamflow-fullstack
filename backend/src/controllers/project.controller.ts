import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { failure, success } from "../utils/response.js";

export const createProject = async (req: AuthRequest, res: Response) => {
  try {
    const { name } = req.body;
    const { teamId } = req.params;

    if (!name) return failure(res, "Project name is required", 400);
    const userId = req.user!.userId;

    const member = await prisma.teamMember.findFirst({
      where: { teamId, userId },
    });

    if (!member) return failure(res, "Not a team member", 403);

    // Only OWNER and ADMIN can create projects
    if (!["OWNER", "ADMIN"].includes(member.role)) {
      return failure(res, "Only admins and owners can create projects", 403);
    }

    const project = await prisma.project.create({
      data: { name, teamId, ownerId: userId },
    });

    return success(res, "Project created successfully", project, 201);
  } catch (error) {
    console.error("Error creating project:", error);
    return failure(res, "Internal server error", 500);
  }
};

export const getProjects = async (req: AuthRequest, res: Response) => {
  try {
    const { teamId } = req.params;
    const userId = req.user!.userId;

    const member = await prisma.teamMember.findFirst({
      where: { teamId, userId },
    });

    if (!member) return failure(res, "Not a team member", 403);

    const projects = await prisma.project.findMany({
      where: { teamId },
      include: {
        _count: { select: { tasks: true } },
      },
      orderBy: { createdAt: "desc" },
    });

    success(res, "Projects fetched successfully", projects);
  } catch (error) {
    console.error("Error fetching projects:", error);
    return failure(res, "Internal server error", 500);
  }
};

export const updateProject = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const { name } = req.body;
    const userId = req.user!.userId;

    const project = await prisma.project.findUnique({ where: { id } });
    if (!project) return failure(res, "Project not found", 404);

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) return failure(res, "Not a team member", 403);

    // Only OWNER and ADMIN can update projects
    if (!["OWNER", "ADMIN"].includes(member.role)) {
      return failure(res, "Only admins and owners can update projects", 403);
    }

    const updatedProject = await prisma.project.update({
      where: { id },
      data: { name },
    });

    success(res, "Project updated successfully", updatedProject);
  } catch (error) {
    console.error("Error updating project:", error);
    return failure(res, "Internal server error", 500);
  }
};

export const deleteProject = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const project = await prisma.project.findUnique({ where: { id } });
    if (!project) return failure(res, "Project not found", 404);

    const member = await prisma.teamMember.findFirst({
      where: { teamId: project.teamId, userId },
    });

    if (!member) return failure(res, "Not a team member", 403);

    // Only OWNER and ADMIN can delete projects
    if (!["OWNER", "ADMIN"].includes(member.role)) {
      return failure(res, "Only admins and owners can delete projects", 403);
    }

    await prisma.project.delete({ where: { id } });

    success(res, "Project deleted successfully", null, 200);
  } catch (error) {
    console.error("Error deleting project:", error);
    return failure(res, "Internal server error", 500);
  }
};
