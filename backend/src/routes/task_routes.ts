import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { createTask, deleteTask, getTasks, updateTask } from '../controllers/task.controller.js';

const router = Router();

router.use(authenticate);
router.post('/create', createTask);
router.get('/:projectId', getTasks);
router.patch('/:id', updateTask);
router.delete('/:id', deleteTask);

export default router;
