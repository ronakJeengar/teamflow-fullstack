import { api } from './client';

export const fetchProjects = async (token: string) => {
  const res = await api.get('/projects', {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.data;
};
