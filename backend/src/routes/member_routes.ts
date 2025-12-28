import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { updateMemberRole, getTeamMembers, removeMember } from '../controllers/member.controller.js';
import { requireTeamRole } from '../middleware/team.role.middleware.js';

const router = Router();
router.use(authenticate);

router.get('/:teamId/members', getTeamMembers);
router.patch('/:teamId/members/:memberId', requireTeamRole(['OWNER']), updateMemberRole);
router.delete('/:teamId/members/:memberId', requireTeamRole(['OWNER']), removeMember);

export default router;
