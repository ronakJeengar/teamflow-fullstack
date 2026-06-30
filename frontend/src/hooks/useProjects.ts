import { useTeams } from "./useTeams";

export const useProjects = (workspaceId?: string | null) => {
  const { data: teams = [], isLoading } = useTeams(workspaceId);

  // Derive projects by flattening the projects array from all loaded teams (matching Flutter)
  const projects = teams.flatMap((t: any) => {
    return (t.projects || []).map((p: any) => ({
      ...p,
      team: {
        id: t.id,
        name: t.name,
        color: t.color,
        workspaceId: t.workspaceId,
      },
    }));
  });

  return {
    data: projects,
    isLoading,
  };
};
