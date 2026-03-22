export type TaskStatus = "TODO" | "IN_PROGRESS" | "DONE";

export interface Task {
  id: string;
  title: string;
  description: string | null;
  status: TaskStatus;

  projectId: string;

  createdById: string;
  assignedToId: string | null;

  createdAt: string;
  updatedAt: string;
}
