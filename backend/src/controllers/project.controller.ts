import { Response } from 'express';
import { prisma } from '../prisma/client.js';
import { AuthRequest } from '../middleware/auth.middleware.js';

export const createProject = async (req: AuthRequest, res: Response) => {

  const { name } = req.body;

  if (!name) return res.status(400).json({ message: "Name is required" });

  const project = await prisma.project.create({
    data: {
      name,
      ownerId: req.user!.userId,
    },
  });

  res.status(201).json(project);
};

export const getProjects = async (req: AuthRequest, res: Response) => {
  const projects = await prisma.project.findMany({
    where: { ownerId: req.user!.userId },
    include: {
      _count: {
        select: { tasks: true }
      }
    },
    orderBy: { createdAt: "desc" },
  });

  res.json(projects);
};

export const updateProject = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { name } = req.body;

  const project = await prisma.project.findUnique({ where: { id } });
  if (!project) return res.status(404).json({ message: "Project not found" });

  if (project.ownerId !== req.user!.userId)
    return res.status(403).json({ message: "Not allowed" });

  const updatedProject = await prisma.project.update({
    where: { id },
    data: { name },
  });

  res.json(updatedProject);
};

export const deleteProject = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  const project = await prisma.project.findUnique({ where: { id } });
  if (!project) return res.status(404).json({ message: "Project not found" });

  if (project.ownerId !== req.user!.userId)
    return res.status(403).json({ message: "Not allowed" });

  await prisma.project.delete({ where: { id } });

  res.status(204).send();
};
