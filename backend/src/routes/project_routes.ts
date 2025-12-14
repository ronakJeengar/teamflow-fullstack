import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { createProject, getProjects } from '../controllers/project.controller.js';

const router = Router();

router.use(authenticate);

router.post('/create', createProject);
router.get('/', getProjects);

export default router;
