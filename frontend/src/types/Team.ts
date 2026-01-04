import type { Project } from "./Project";
import type { TeamInvitation } from "./TeamInvitation";
import type { TeamMember } from "./TeamMember";

export type Team = {
  id: string;
  name: string;
  description?: string | null;
  avatar?: string | null;

  ownerId: string;

  // if you load relations, these can be populated
  members: TeamMember[];
  projects: Project[];
  invitations: TeamInvitation[];

  createdAt: string;
  updatedAt: string;
};
