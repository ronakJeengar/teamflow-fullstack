import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";
import { teamMembersKey } from "../lib/queryKeys";

export const useTeamMembers = (teamId: string) => {
  return useQuery({
    queryKey: teamMembersKey(teamId),
    queryFn: async () => {
      const res = await api.get(`/teams/${teamId}/members`);
      return res.data;
    },
  });
};
