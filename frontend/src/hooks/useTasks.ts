import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";

export const useTasks = (projectId: string) =>
  useQuery({
    queryKey: ["tasks", projectId],
    queryFn: async () => {
      const res = await api.get(`/tasks/project/${projectId}`);
      return res.data?.data ?? [];
    },
    enabled: !!projectId,
  });
