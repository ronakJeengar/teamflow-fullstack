import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Team } from "../types/Team";

export const useTeams = (workspaceId?: string | null) =>
  useQuery<Team[]>({
    queryKey: ["teams", workspaceId],
    queryFn: async () => {
      const res = await api.get("/teams");
      const allTeams = res.data?.data ?? [];
      if (!workspaceId) return allTeams;
      return allTeams.filter((t: any) => !t.workspaceId || t.workspaceId === workspaceId);
    },
  });
