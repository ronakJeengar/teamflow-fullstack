import type { Task } from "./Task.js";

export type UpdateTask = {
  id: string;
} & Partial<Omit<Task, "id">>;
