import type { Project } from "./Project.js";

export type UpdateProject = {
  id: string;
} & Partial<Omit<Project, "id">>;
