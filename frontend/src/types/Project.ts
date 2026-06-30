export interface Project {
  id: string;
  name: string;
  description: string | null;
  color: string | null;
  visibility: "PUBLIC" | "PRIVATE";
  ownerId: string;
  teamId: string;
  createdAt: string;
  updatedAt: string;
  team?: {
    id: string;
    name: string;
    workspaceId: string;
  };
  _count?: {
    tasks: number;
  };
}