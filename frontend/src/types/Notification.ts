export interface Notification {
  id: string;
  userId: string;
  senderId: string | null;
  type: string;
  title: string;
  body: string;
  taskId: string | null;
  projectId: string | null;
  teamId: string | null;
  isRead: boolean;
  createdAt: string;
  sender?: {
    id: string;
    name: string;
    avatar: string | null;
  } | null;
}
