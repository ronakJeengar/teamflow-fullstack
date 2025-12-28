import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";

type CreateTaskPayload = {
  title: string;
  description?: string;
};

export const useCreateTask = (projectId: string) => {
  const qc = useQueryClient();

  return useMutation({
    mutationFn: async ({ title, description }: CreateTaskPayload) => {
      const res = await api.post(
        "/tasks/create",
        { title, description, projectId },
      );
      return res.data;
    },


    onSuccess: () => {
      qc.invalidateQueries({
        queryKey: ["tasks", projectId],
      });
    },
  });
};

