import { Response } from 'express';
import { prisma } from '../prisma/client.js';
import { AuthRequest } from '../middleware/auth.middleware.js';
import { createTaskSchema } from '../utils/task.schema.js';
import { io } from '../server.js';

export const createTask = async (req: AuthRequest, res: Response) => {
    const data = createTaskSchema.parse(req.body);

    const task = await prisma.task.create({
        data,
    });

    await prisma.activityLog.create({
        data: {
            action: `Created task ${task.title}`,
            userId: req.user!.userId,
            projectId: task.projectId,
        },
    });

    io.emit('task:created', task);
    res.status(201).json(task);
};

export const getTasks = async (req: AuthRequest, res: Response) => {
    const { projectId } = req.params;
    const { page = '1', q = '' } = req.query;

    const pageNumber = Number(page);
    const pageSize = 10;

    const tasks = await prisma.task.findMany({
        where: {
            projectId,
            title: {
                contains: q as string,
                mode: 'insensitive',
            },
        },
        skip: (pageNumber - 1) * pageSize,
        take: pageSize,
        orderBy: {
            createdAt: 'desc',
        },
    });

    const total = await prisma.task.count({
        where: {
            projectId,
            title: {
                contains: q as string,
                mode: 'insensitive',
            },
        },
    });

    res.json({
        data: tasks,
        meta: {
            page: pageNumber,
            pageSize,
            total,
            totalPages: Math.ceil(total / pageSize),
        },
    });
};

export const updateTask = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;
  const { title, description, status } = req.body;

  const task = await prisma.task.findUnique({
    where: { id },
  });

  if (!task) {
    return res.status(404).json({ message: 'Task not found' });
  }

  const updatedTask = await prisma.task.update({
    where: { id },
    data: {
      title,
      description,
      status,
    },
  });

  // activity log
  await prisma.activityLog.create({
    data: {
      action: `Updated task ${updatedTask.title}`,
      userId: req.user!.userId,
      projectId: updatedTask.projectId,
    },
  });

  // realtime event
  io.emit('task:updated', updatedTask);

  res.json(updatedTask);
};

export const deleteTask = async (req: AuthRequest, res: Response) => {
  const { id } = req.params;

  const task = await prisma.task.findUnique({
    where: { id },
  });

  if (!task) {
    return res.status(404).json({ message: 'Task not found' });
  }

  await prisma.task.delete({
    where: { id },
  });

  await prisma.activityLog.create({
    data: {
      action: `Deleted task ${task.title}`,
      userId: req.user!.userId,
      projectId: task.projectId,
    },
  });

  io.emit('task:deleted', { id });

  res.status(204).send();
};


