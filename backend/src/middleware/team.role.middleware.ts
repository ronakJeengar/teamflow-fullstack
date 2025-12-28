import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth.middleware.js';
import { prisma } from '../prisma/client.js';

export const requireTeamRole = (allowedRoles: string[]) => {
    return async (req: AuthRequest, res: Response, next: NextFunction) => {
        const userId = req.user?.userId;
        const teamId = req.params.teamId;

        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const member = await prisma.teamMember.findFirst({
            where: { teamId, userId },
        });

        if (!member) return res.status(403).json({ message: 'Forbidden: not a team member' });
        if (!allowedRoles.includes(member.role))
            return res.status(403).json({ message: 'Forbidden: insufficient role' });

        next();
    };
};
