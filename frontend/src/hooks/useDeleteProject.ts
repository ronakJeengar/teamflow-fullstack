import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Project } from "../types/Project";

export const useDeleteProject = () => {
  const queryClient = useQueryClient();

  return useMutation<string, Error, string, { previous?: Project[] }>({
    mutationFn: async (id) => {
      await api.delete(`/projects/${id}`);
      return id;
    },

    // --- Optimistic UI ---
    onMutate: async (projectId) => {
      await queryClient.cancelQueries({
        queryKey: ["projects"],
      });

      const previous = queryClient.getQueryData<Project[]>(["projects"]);

      queryClient.setQueryData<Project[]>(["projects"], (old) =>
        old?.filter((p) => p.id !== projectId)
      );

      return { previous };
    },

    // --- Rollback on error ---
    onError: (_err, _vars, ctx) => {
      if (ctx?.previous) {
        queryClient.setQueryData(["projects"], ctx.previous);
      }
    },

    // --- Always refresh ---
    onSettled: () => {
      queryClient.invalidateQueries({
        queryKey: ["projects"],
      });
    },
  });
};
