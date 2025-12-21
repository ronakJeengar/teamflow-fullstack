import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Task } from "../types/Task";

type CreateTaskInput = {
  title: string;
  description?: string;
  projectId: string;
};

export const useCreateTask = () => {
  const queryClient = useQueryClient();

  return useMutation<Task, Error, CreateTaskInput>({
    mutationFn: async (payload) => {
      const token = localStorage.getItem("token")!;
      const res = await api.post("/tasks", payload, {
        headers: { Authorization: `Bearer ${token}` },
      });

      return res.data;
    },

    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({
        queryKey: ["tasks", variables.projectId],
      });
    },
  });
};
