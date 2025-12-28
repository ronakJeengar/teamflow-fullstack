import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";

export const useCreateProject = () => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: async ({ name }: { name: string }) => {
      const res = await api.post(
        "/projects/create",
        { name });
      return res.data;
    },

    onSuccess: () => {
      qc.invalidateQueries({
        queryKey: ["projects"],
      });
    },
  });
};
