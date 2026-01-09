import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { teamMembersKey } from "../lib/queryKeys";

export const useAddMember = (teamId: string) => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: async (payload: { userId: string; role?: string }) => {
      const res = await api.post(`/teams/${teamId}/members`, payload);
      return res.data;
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: teamMembersKey(teamId) });
    },
  });
};
