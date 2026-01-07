import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import type { Team } from "../types/Team";

export const useDeleteTeam = () => {
  const queryClient = useQueryClient();

  return useMutation<string, Error, string, { previous?: Team[] }>({
    mutationFn: async (id) => {
      console.log("Deleting team with id:", id);
      await api.delete(`/teams/${id}`);
      return id;
    },

    // --- Optimistic UI ---
    onMutate: async (teamId) => {
      await queryClient.cancelQueries({
        queryKey: ["teams"],
      });

      const previous = queryClient.getQueryData<Team[]>(["teams"]);

      queryClient.setQueryData<Team[]>(["teams"], (old) =>
        old?.filter((t) => t.id !== teamId)
      );

      return { previous };
    },

    // --- Rollback on error ---
    onError: (_err, _vars, ctx) => {
      if (ctx?.previous) {
        queryClient.setQueryData(["teams"], ctx.previous);
      }
    },

    // --- Always refresh ---
    onSettled: () => {
      queryClient.invalidateQueries({
        queryKey: ["teams"],
      });
    },
  });
};
