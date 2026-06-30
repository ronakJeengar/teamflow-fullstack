import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Project } from "../types/Project";

export const useProject = (projectId: string) =>
  useQuery<Project>({
    queryKey: ["project", projectId],
    queryFn: async () => {
      if (!projectId) throw new Error("Project ID is required");
      const res = await api.get(`/projects/${projectId}`);
      // In backend, getProjectById returns the project object directly under res.data.data
      return res.data?.data;
    },
    enabled: !!projectId,
  });
