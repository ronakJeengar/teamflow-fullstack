import { Response } from 'express';
import { prisma } from '../prisma/client.js';
import { AuthRequest } from '../middleware/auth.middleware.js';

export const createProject = async (req: AuthRequest, res: Response) => {
  const project = await prisma.project.create({
    data: {
      name: req.body.name,
      ownerId: req.user!.userId,
    },
  });

  res.status(201).json(project);
};

export const getProjects = async (req: AuthRequest, res: Response) => {
  const projects = await prisma.project.findMany({
    where: { ownerId: req.user!.userId },
  });

  res.json(projects);
};
