import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { createTeam, deleteTeam, getMyTeams, getTeamDetails, updateTeam } from '../controllers/team.controller.js';
import { requireTeamRole } from '../middleware/team.role.middleware.js';

const router = Router();

router.use(authenticate);

router.post('/create', createTeam);
router.get('/', getMyTeams);
router.get('/:teamId', getTeamDetails);
router.patch('/:teamId', requireTeamRole(['OWNER']), updateTeam);
router.delete('/:teamId', requireTeamRole(['OWNER']), deleteTeam);

export default router;
