import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { createTask, getTasks } from '../controllers/task.controller.js';

const router = Router();

router.use(authenticate);
router.post('/create', createTask);
router.get('/:projectId', getTasks);

export default router;
