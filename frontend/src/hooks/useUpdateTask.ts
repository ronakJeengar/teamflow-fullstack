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

            // Get previous tasks from the cache
            const previous = queryClient.getQueryData<{ data: Task[] }>([
                "tasks",
                projectId,
            ])?.data;

            // Optimistically update cache
            queryClient.setQueryData<{ data: Task[] } | undefined>(
                ["tasks", projectId],
                (old) => {
                    if (!old?.data) return old;
                    return {
                        ...old,
                        data: old.data.map((task) =>
                            task.id === updatedTask.id ? { ...task, ...updatedTask } : task
                        ),
                    };
                }
            );

            return { previous };
        },

        onError: (_err, _vars, ctx) => {
            if (ctx?.previous) {
                queryClient.setQueryData<{ data: Task[] }>(["tasks", projectId], (old) => ({
                    ...old!,
                    data: ctx.previous!,
                }));
            }
        },

        onSettled: () => {
            queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
        },
    });
};
