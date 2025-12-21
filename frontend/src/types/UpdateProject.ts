import type { Project } from "./Project";

export type UpdateProject = {
  id: string;
} & Partial<Omit<Project, "id">>;
