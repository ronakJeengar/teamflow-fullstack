import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client.js";
import type { Project } from "../types/Project";
import type { Team } from "../types/Team.js";

export type UpdateTeam = {
    id: string;
    name?: string;
};

export const useUpdateTeam = () => {
    const queryClient = useQueryClient();

    return useMutation<Project, Error, UpdateTeam, { previous?: Team[] }>({
        mutationFn: async ({ id, ...payload }) => {
            const res = await api.patch(`/teams/${id}`, payload);
            return res.data;
        },

        // --- Optimistic Update ---
        onMutate: async (updatedTeam) => {
            await queryClient.cancelQueries({ queryKey: ["teams"] });

            const previous = queryClient.getQueryData<Team[]>(["teams"]);

            queryClient.setQueryData<Project[]>(["teams"], (old) =>
                old?.map((team) =>
                    team.id === updatedTeam.id
                        ? { ...team, ...updatedTeam }
                        : team
                )
            );

            return { previous };
        },

        // --- Rollback on Error ---
        onError: (_err, _vars, ctx) => {
            if (ctx?.previous) {
                queryClient.setQueryData(["teams"], ctx.previous);
            }
        },

        // --- Refetch to Sync ---
        onSettled: () => {
            queryClient.invalidateQueries({ queryKey: ["teams"] });
        },
    });
};
