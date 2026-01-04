import type { Team } from "./Team";
import type { TeamMemberRole } from "./TeamMember";

export type InvitationStatus = 
  | "PENDING"
  | "ACCEPTED"
  | "EXPIRED"
  | "CANCELLED";

export type TeamInvitation = {
  id: string;
  teamId: string;
  email: string;
  role: TeamMemberRole;
  token: string;
  status: InvitationStatus;
  invitedBy: string;
  expiresAt: string;
  createdAt: string;
  team?: Team;
};
