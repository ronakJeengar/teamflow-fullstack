import { useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from '../api/client';

export const useCreateTask = () => {
  const queryClient = useQueryClient();

  return useMutation(
    async (payload: {
      title: string;
      description?: string;
      projectId: string;
    }) => {
      const token = localStorage.getItem('token')!;
      const res = await api.post('/tasks', payload, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      return res.data;
    },
    {
      onSuccess: (_, variables) => {
        queryClient.invalidateQueries(['tasks', variables.projectId]);
      },
    }
  );
};
