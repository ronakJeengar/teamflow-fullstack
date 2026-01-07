import { Response } from "express";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";

export const createProject = async (req: AuthRequest, res: Response) => {
  const { name } = req.body;
  const { teamId } = req.params;

  if (!name) return res.status(400).json({ message: "Name is required" });

  const userId = req.user!.userId;

  const member = await prisma.teamMember.findFirst({
    where: { teamId, userId },
  });

  if (!member) return res.status(403).json({ message: "Not a team member" });

  const project = await prisma.project.create({
    data: {
      name,
      teamId,
      ownerId: userId,
    },
  });

  res.status(201).json(project);
};

export const getProjects = async (req: AuthRequest, res: Response) => {
  const { teamId } = req.params;
  const userId = req.user!.userId;

  const member = await prisma.teamMember.findFirst({
    where: { teamId, userId },
  });

  if (!member) return res.status(403).json({ message: "Not a team member" });

  const projects = await prisma.project.findMany({
    where: { teamId },
    include: {
      _count: { select: { tasks: true } },
    },
    orderBy: { createdAt: "desc" },
  });

  res.json(projects);
};

export const updateProject = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { name } = req.body;

  const userId = req.user!.userId;

  const project = await prisma.project.findUnique({ where: { id } });
  if (!project) return res.status(404).json({ message: "Project not found" });

  const member = await prisma.teamMember.findFirst({
    where: { teamId: project.teamId, userId },
  });

  const isProjectOwner = project.ownerId === userId;
  const isPrivilegedMember = member && ["OWNER", "ADMIN"].includes(member.role);

  if (!isProjectOwner && !isPrivilegedMember) {
    return res.status(403).json({ message: "Not allowed" });
  }

  const updatedProject = await prisma.project.update({
    where: { id },
    data: { name },
  });

  res.json(updatedProject);
};

export const deleteProject = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const userId = req.user!.userId;
  console.log("Delete project request for ID:", id, "by user:", userId);

  const project = await prisma.project.findUnique({ where: { id } });
  if (!project) return res.status(404).json({ message: "Project not found" });

  const member = await prisma.teamMember.findFirst({
    where: { teamId: project.teamId, userId },
  });

  const isProjectOwner = project.ownerId === userId;
  const isTeamAdminOrOwner = member && ["OWNER", "ADMIN"].includes(member.role);

  if (!isProjectOwner && !isTeamAdminOrOwner) {
    return res.status(403).json({ message: "Not allowed" });
  }

  await prisma.project.delete({ where: { id } });

  res.status(204).send();
};
