import { useQuery } from '@tanstack/react-query';
import { api } from '../api/client';

export const useTasks = (projectId: string) =>
  useQuery({
    queryKey: ['tasks', projectId],
    queryFn: async () => {
      const token = localStorage.getItem('token')!;
      const res = await api.get(`/tasks/${projectId}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      console.log('Raw API response:', res.data);
      return res.data;
    },
    enabled: !!projectId,
  });
