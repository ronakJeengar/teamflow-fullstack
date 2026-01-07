import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Team } from "../types/Team";

export const useDeleteProject = (teamId: string) => {
  const queryClient = useQueryClient();

  return useMutation<string, Error, string, { previous?: Team }>({
    mutationFn: async (id) => {
      await api.delete(`/projects/${teamId}/${id}`);
      return id;
    },

    // --- Optimistic UI ---
    onMutate: async (projectId) => {
      await queryClient.cancelQueries({ queryKey: ["team", teamId] });

      const previous = queryClient.getQueryData<Team>(["team", teamId]);

      queryClient.setQueryData<Team>(["team", teamId], (old) => {
        if (!old) return old;

        return {
          ...old,
          projects: old.projects.filter((project) => project.id !== projectId),
        };
      });

      return { previous };
    },

    // --- Rollback on error ---
    onError: (_err, _vars, ctx) => {
      if (ctx?.previous) {
        queryClient.setQueryData(["team", teamId], ctx.previous);
      }
    },

    // --- Always refresh ---
    onSettled: () => {
      queryClient.invalidateQueries({
        queryKey: ["team", teamId],
      });
    },
  });
};
