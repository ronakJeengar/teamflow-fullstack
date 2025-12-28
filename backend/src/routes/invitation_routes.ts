import { Router } from 'express';
import { authenticate } from '../middleware/auth.middleware.js';
import { requireTeamRole } from '../middleware/team.role.middleware.js';
import { acceptInvitation, cancelInvitation, sendInvitation } from '../controllers/invitation.controller.js';

const router = Router();
router.use(authenticate);

router.post('/:teamId/invitations', requireTeamRole(['OWNER', 'ADMIN']), sendInvitation);
router.post('/accept', acceptInvitation);
router.delete('/:teamId/invitations/:invitationId', requireTeamRole(['OWNER', 'ADMIN']), cancelInvitation);

export default router;
