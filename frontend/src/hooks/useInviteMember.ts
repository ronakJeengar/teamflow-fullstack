import { useMutation } from "@tanstack/react-query";
import { api } from "../api/client";

export const useInviteMember = (teamId: string) => {
  return useMutation({
    mutationFn: async ({ email, role }: { email: string; role: string }) => {
      const res = await api.post(`/teams/${teamId}/invitations`, {
        email,
        role,
      });
      return res.data;
    },
  });
};
