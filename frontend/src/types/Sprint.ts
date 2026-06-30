export type SprintStatus = "PLANNED" | "ACTIVE" | "COMPLETED" | "CANCELLED";

export interface Sprint {
  id: string;
  name: string;
  goal: string | null;
  startDate: string | null;
  endDate: string | null;
  status: SprintStatus;
  teamId: string;
  workspaceId: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}
