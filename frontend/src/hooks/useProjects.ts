import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Project } from "../types/Project";

export const useProjects = (workspaceId?: string | null) =>
  useQuery<Project[]>({
    queryKey: ["projects", workspaceId],
    queryFn: async () => {
      const res = await api.get("/projects");
      const allProjects = res.data?.data ?? [];
      if (!workspaceId) return allProjects;
      return allProjects.filter(
        (p: any) => !p.team?.workspaceId || p.team?.workspaceId === workspaceId
      );
    },
  });
