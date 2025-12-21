import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";

export const useCreateProject = () => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: async ({ name }: { name: string }) => {
      const token = localStorage.getItem("token")!;
      const res = await api.post(
        "/projects",
        { name },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      return res.data;
    },

    onSuccess: () => {
      qc.invalidateQueries({
        queryKey: ["projects"],
      });
    },
  });
};
