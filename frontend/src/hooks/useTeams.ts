import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Team } from "../types/Team";

export const useTeams = (workspaceId?: string | null) =>
  useQuery<Team[]>({
    queryKey: ["teams", workspaceId],
    queryFn: async () => {
      if (!workspaceId) return [];
      const res = await api.get("/teams", {
        params: { workspaceId },
      });
      return res.data.data;
    },
    enabled: !!workspaceId,
  });
