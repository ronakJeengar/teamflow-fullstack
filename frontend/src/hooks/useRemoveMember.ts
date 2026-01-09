import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { teamMembersKey } from "../lib/queryKeys";

export const useRemoveMember = (teamId: string) => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: async (memberId: string) => {
      await api.delete(`/teams/${teamId}/members/${memberId}`);
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: teamMembersKey(teamId) });
    },
  });
};
