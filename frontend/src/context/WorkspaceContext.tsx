import { createContext, useContext, useState, useEffect, type ReactNode } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import type { Workspace } from "../types/Workspace";

interface WorkspaceContextType {
  activeWorkspaceId: string | null;
  activeWorkspace: Workspace | null;
  workspaces: Workspace[];
  switchWorkspace: (id: string) => Promise<void>;
  isLoading: boolean;
  refetchWorkspaces: () => void;
}

const WorkspaceContext = createContext<WorkspaceContextType | undefined>(undefined);

export const WorkspaceProvider = ({ children }: { children: ReactNode }) => {
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const [activeWorkspaceId, setActiveWorkspaceId] = useState<string | null>(
    user?.activeWorkspaceId || localStorage.getItem("active_workspace_id")
  );

  // Fetch workspaces list
  const { data: workspaces = [], isLoading, refetch } = useQuery<Workspace[]>({
    queryKey: ["workspaces"],
    queryFn: async () => {
      const res = await api.get("/workspaces");
      return res.data.data;
    },
    enabled: !!user,
  });

  // Keep state synced with user activeWorkspaceId on login/session restore
  useEffect(() => {
    if (user?.activeWorkspaceId) {
      setActiveWorkspaceId(user.activeWorkspaceId);
      localStorage.setItem("active_workspace_id", user.activeWorkspaceId);
    }
  }, [user]);

  // Find active workspace details
  const activeWorkspace = workspaces.find((w) => w.id === activeWorkspaceId) || null;

  const switchWorkspace = async (id: string) => {
    try {
      await api.post(`/workspaces/${id}/switch`);
      setActiveWorkspaceId(id);
      localStorage.setItem("active_workspace_id", id);
      
      // Invalidate all query caches to prevent stale cross-workspace leakage
      queryClient.invalidateQueries();
    } catch (err) {
      console.error("Error switching workspace:", err);
    }
  };

  return (
    <WorkspaceContext.Provider
      value={{
        activeWorkspaceId,
        activeWorkspace,
        workspaces,
        switchWorkspace,
        isLoading,
        refetchWorkspaces: refetch,
      }}
    >
      {children}
    </WorkspaceContext.Provider>
  );
};

export const useWorkspace = () => {
  const context = useContext(WorkspaceContext);
  if (!context) {
    throw new Error("useWorkspace must be used within a WorkspaceProvider");
  }
  return context;
};
