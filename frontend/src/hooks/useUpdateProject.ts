import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client.js";
import type { Project } from "../types/Project.js";

export type UpdateProject = {
  id: string;
  name?: string;
};

export const useUpdateProject = () => {
  const queryClient = useQueryClient();

  return useMutation<Project, Error, UpdateProject, { previous?: Project[] }>({
    mutationFn: async ({ id, ...payload }) => {
      const token = localStorage.getItem("token")!;
      const res = await api.patch(`/projects/${id}`, payload, {
        headers: { Authorization: `Bearer ${token}` },
      });

      return res.data;
    },

    // --- Optimistic Update ---
    onMutate: async (updatedProject) => {
      await queryClient.cancelQueries({ queryKey: ["projects"] });

      const previous = queryClient.getQueryData<Project[]>(["projects"]);

      queryClient.setQueryData<Project[]>(["projects"], (old) =>
        old?.map((project) =>
          project.id === updatedProject.id
            ? { ...project, ...updatedProject }
            : project
        )
      );

      return { previous };
    },

    // --- Rollback on Error ---
    onError: (_err, _vars, ctx) => {
      if (ctx?.previous) {
        queryClient.setQueryData(["projects"], ctx.previous);
      }
    },

    // --- Refetch to Sync ---
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["projects"] });
    },
  });
};
