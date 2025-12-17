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

    io.emit('task:created', task); 
    res.status(201).json(task);
};

export const getTasks = async (req: AuthRequest, res: Response) => {
    const tasks = await prisma.task.findMany({
        where: { projectId: req.params.projectId },
    });

    res.json(tasks);
};
