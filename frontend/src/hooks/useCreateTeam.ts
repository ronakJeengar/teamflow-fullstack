import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";

type CreateTeamInput = {
    name: string;
    description?: string;
    avatar?: string;
};

export const useCreateTeam = () => {
    const qc = useQueryClient();

    return useMutation({
        mutationFn: async (payload: CreateTeamInput) => {
            const res = await api.post(
                "/teams/create",
                payload
            );
            return res.data;
        },

        onSuccess: () => {
            qc.invalidateQueries({
                queryKey: ["teams"],
            });
        },
    });
};
