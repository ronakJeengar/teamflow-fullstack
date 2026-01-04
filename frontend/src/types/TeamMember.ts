import type { User } from "../auth/AuthContext";
import type { Team } from "./Team";

export type TeamMemberRole = "OWNER" | "ADMIN" | "MEMBER" | "VIEWER";

export type TeamMember = {
  id: string;
  teamId: string;
  userId: string;
  role: TeamMemberRole;
  joinedAt: string;
  team?: Team;
  user?: User;
};
