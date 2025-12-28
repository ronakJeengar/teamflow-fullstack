import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { createProject, deleteProject, getProjects, updateProject } from '../controllers/project.controller.js';
import { requireTeamRole } from '../middleware/team.role.middleware.js';

const router = Router();

router.use(authenticate);

router.post('/:teamId/create', requireTeamRole(['OWNER', 'ADMIN', 'MEMBER']), createProject);
router.get('/:teamId', requireTeamRole(['OWNER', 'ADMIN', 'MEMBER', 'VIEWER']), getProjects);
router.patch("/:id", updateProject);
router.delete("/:id", deleteProject);

export default router;
