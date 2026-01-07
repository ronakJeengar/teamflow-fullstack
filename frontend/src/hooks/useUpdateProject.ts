import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client.js";
import type { Project } from "../types/Project";
import type { Team } from "../types/Team.js";

export type UpdateProject = {
  id: string;
  name?: string;
};

export const useUpdateProject = (teamId: string) => {
  const qc = useQueryClient();

  return useMutation<Project, Error, UpdateProject, { previous?: Team }>({
    mutationFn: async ({ id, ...payload }) => {
      const res = await api.patch(`/projects/${teamId}/${id}`, payload);

      return res.data;
    },

    // --- Optimistic Update ---
    onMutate: async (updatedProject) => {
      // await qc.cancelQueries({ queryKey: ["team", teamId] });

      // const previous = qc.getQueryData<Project[]>(["team", teamId]);

      // qc.setQueryData<Project[]>(["team", teamId], (old) =>
      //   old?.map((project) =>
      //     project.id === updatedProject.id
      //       ? { ...project, ...updatedProject }
      //       : project
      //   )
      // );

      // return { previous };
      await qc.cancelQueries({ queryKey: ["team", teamId] });

      const previous = qc.getQueryData<Team>(["team", teamId]);

      qc.setQueryData<Team>(["team", teamId], (old) => {
        if (!old) return old;

        return {
          ...old,
          projects: old.projects.map((project) =>
            project.id === updatedProject.id
              ? { ...project, ...updatedProject }
              : project
          ),
        };
      });

      return { previous };
    },

    // --- Rollback on Error ---
    onError: (_err, _vars, ctx) => {
      if (ctx?.previous) {
        qc.setQueryData(["team", teamId], ctx.previous);
      }
    },

    // --- Refetch to Sync ---
    onSettled: () => {
      // qc.invalidateQueries({ queryKey: ["projects"] });
      qc.invalidateQueries({
        queryKey: ["team", teamId],
      });
    },
  });
};
