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
