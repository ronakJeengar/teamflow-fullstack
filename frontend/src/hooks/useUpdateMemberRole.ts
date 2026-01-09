import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { teamMembersKey } from "../lib/queryKeys";

export const useUpdateMemberRole = (teamId: string) => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: async ({
      memberId,
      role,
    }: {
      memberId: string;
      role: string;
    }) => {
      const res = await api.patch(`/teams/${teamId}/members/${memberId}`, {
        role,
      });
      return res.data;
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: teamMembersKey(teamId) });
    },
  });
};
