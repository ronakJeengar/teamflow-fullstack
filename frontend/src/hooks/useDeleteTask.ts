import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Task } from "../types/Task";

export const useDeleteTask = (projectId: string) => {
  const queryClient = useQueryClient();

  return useMutation<string, Error, string, { previous?: Task[] }>({
    mutationFn: async (id) => {
      const token = localStorage.getItem("token")!;
      await api.delete(`/tasks/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      return id;
    },

    // Optimistic UI
    onMutate: async (taskId) => {
      await queryClient.cancelQueries({
        queryKey: ["tasks", projectId],
      });

      const previous = queryClient.getQueryData<Task[]>([
        "tasks",
        projectId,
      ]);

      queryClient.setQueryData<Task[]>(["tasks", projectId], (old) =>
        old?.filter((t) => t.id !== taskId)
      );

      return { previous };
    },

    onError: (_err, _vars, ctx) => {
      if (ctx?.previous) {
        queryClient.setQueryData(["tasks", projectId], ctx.previous);
      }
    },

    onSettled: () => {
      queryClient.invalidateQueries({
        queryKey: ["tasks", projectId],
      });
    },
  });
};
