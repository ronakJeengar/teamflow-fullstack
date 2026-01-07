import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";

export const useCreateProject = (teamId: string) => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: async ({ name }: { name: string }) => {
      const res = await api.post(`/projects/${teamId}/create`, { name });
      return res.data;
    },

    onSuccess: () => {
      qc.invalidateQueries({
        queryKey: ["team", teamId],
      });
    },
  });
};
