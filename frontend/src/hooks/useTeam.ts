import { useQuery } from '@tanstack/react-query';
import { api } from '../api/client';

export const useTeam = (teamId: string) =>
  useQuery({
    queryKey: ['team', teamId],
    queryFn: async () => {
      const res = await api.get(`/teams/${teamId}`);
      console.log('Raw API response:', res.data);
      return res.data;
    },
    enabled: !!teamId,
  });
