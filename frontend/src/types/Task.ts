export type TaskStatus = "TODO" | "IN_PROGRESS" | "REVIEW" | "BLOCKED" | "DONE";
export type TaskPriority = "LOW" | "MEDIUM" | "HIGH" | "URGENT";

export interface Task {
  id: string;
  title: string;
  description: string | null;
  status: TaskStatus;
  priority: TaskPriority;
  projectId: string;
  sprintId: string | null;
  storyPoints: number | null;
  isBacklog: boolean;
  createdById: string;
  assignedToId: string | null;
  dueDate?: string | null;
  assignedTo?: {
    id: string;
    name: string;
    avatar: string | null;
  } | null;
  createdAt: string;
  updatedAt: string;
}
