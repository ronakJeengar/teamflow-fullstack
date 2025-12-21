import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client.js";
import type { Task } from "../types/Task.js";
import type { UpdateTask } from "../types/UpdateTask.js";

export const useUpdateTask = (projectId: string) => {
    const queryClient = useQueryClient();

    return useMutation<Task, Error, UpdateTask, { previous?: Task[] }>({
        mutationFn: async ({ id, ...payload }) => {
            const token = localStorage.getItem("token")!;
            const res = await api.patch(`/tasks/${id}`, payload, {
                headers: { Authorization: `Bearer ${token}` },
            });
            return res.data;
        },

        onMutate: async (updatedTask) => {
            await queryClient.cancelQueries({ queryKey: ["tasks", projectId] });

            const previous = queryClient.getQueryData<Task[]>([
                "tasks",
                projectId,
            ]);

            queryClient.setQueryData<Task[]>(["tasks", projectId], (old) =>
                old?.map((task) =>
                    task.id === updatedTask.id ? { ...task, ...updatedTask } : task
                )
            );

            return { previous };
        },

        onError: (_err, _vars, ctx) => {
            if (ctx?.previous) {
                queryClient.setQueryData(["tasks", projectId], ctx.previous);
            }
        },

        onSettled: () => {
            queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
        },
    });
};
