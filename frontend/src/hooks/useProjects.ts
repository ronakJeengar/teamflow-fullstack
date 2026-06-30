import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Project } from "../types/Project";

export const useProjects = (workspaceId?: string | null) =>
  useQuery<Project[]>({
    queryKey: ["projects", workspaceId],
    queryFn: async () => {
      if (!workspaceId) return [];
      const res = await api.get("/projects", {
        params: { workspaceId },
      });
      return res.data.data;
    },
    enabled: !!workspaceId,
  });
