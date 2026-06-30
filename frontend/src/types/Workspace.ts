export interface Workspace {
  id: string;
  name: string;
  color: string;
  slug: string;
  createdAt: string;
  updatedAt: string;
}

export interface WorkspaceMember {
  id: string;
  workspaceId: string;
  userId: string;
  role: "OWNER" | "ADMIN" | "MEMBER" | "VIEWER";
  createdAt: string;
  user: {
    id: string;
    name: string;
    email: string;
    avatar: string | null;
  };
}
