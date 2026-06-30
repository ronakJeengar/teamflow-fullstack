export interface Activity {
  id: string;
  workspaceId: string;
  teamId: string | null;
  projectId: string | null;
  taskId: string | null;
  userId: string;
  type: string;
  description: string;
  metadata: Record<string, any>;
  createdAt: string;
  user?: {
    id: string;
    name: string;
    avatar: string | null;
  } | null;
}
