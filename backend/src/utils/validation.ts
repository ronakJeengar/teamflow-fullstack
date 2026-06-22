import { z } from 'zod'

export const createTaskSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().optional().nullable(),
  status: z.enum(['TODO', 'IN_PROGRESS', 'REVIEW', 'BLOCKED', 'DONE']).optional(),
  priority: z.enum(['LOW', 'MEDIUM', 'HIGH', 'URGENT']).optional(),
  dueDate: z.string().datetime().optional().nullable(),
  tags: z.array(z.string()).optional(),
  projectId: z.string().uuid(),
  assignedToId: z.string().uuid().optional().nullable(),
})

export const updateTaskSchema = createTaskSchema.partial().omit({ projectId: true })

export const createCommentSchema = z.object({
  content: z.string().min(1).max(2000),
})

export const createWorkspaceSchema = z.object({
  name: z.string().min(1).max(100),
  color: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
})

export const searchSchema = z.object({
  q: z.string().min(1).max(100),
  type: z.enum(['all', 'tasks', 'projects', 'teams']).optional().default('all'),
  limit: z.coerce.number().min(1).max(50).optional().default(10),
})
