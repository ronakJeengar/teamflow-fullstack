import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { createProject, deleteProject, getProjects, updateProject } from '../controllers/project.controller.js';

const router = Router();

router.use(authenticate);

router.post('/create', createProject);
router.get('/', getProjects);
router.patch("/:id", updateProject);
router.delete("/:id", deleteProject);

export default router;
