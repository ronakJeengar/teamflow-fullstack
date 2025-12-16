import { z } from 'zod';

export const createTaskSchema = z.object({
    title: z.string().min(1),
    description: z.string().optional(),
    projectId: z.string().uuid(),
});
