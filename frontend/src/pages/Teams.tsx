import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useToast } from "../context/useToast";
import { useTeams } from "../hooks/useTeams";
import type { Team } from "../types/Team";

export default function Teams() {
  const { activeWorkspaceId } = useWorkspace();
  const { showToast } = useToast();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const [editingTeam, setEditingTeam] = useState<Team | null>(null);
  const [editName, setEditName] = useState("");
  const [editDesc, setEditDesc] = useState("");

  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createName, setCreateName] = useState("");
  const [createDesc, setCreateDesc] = useState("");

  // 1. Fetch Teams list scoped by activeWorkspaceId
  const { data: teams = [], isLoading } = useTeams(activeWorkspaceId);

  // Create Team Mutation
  const createTeamMutation = useMutation({
    mutationFn: async () => {
      await api.post("/teams", {
        name: createName,
        description: createDesc || null,
        workspaceId: activeWorkspaceId,
      });
    },
    onSuccess: () => {
      showToast("Team created successfully!", "success");
      setCreateName("");
      setCreateDesc("");
      setShowCreateModal(false);
      queryClient.invalidateQueries({ queryKey: ["teams", activeWorkspaceId] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-stats", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to create team", "error");
    },
  });

  // Update Team Mutation
  const updateTeamMutation = useMutation({
    mutationFn: async ({ id, name, description }: { id: string; name: string; description: string }) => {
      await api.patch(`/teams/${id}`, { name, description });
    },
    onSuccess: () => {
      showToast("Team updated successfully!", "success");
      setEditingTeam(null);
      queryClient.invalidateQueries({ queryKey: ["teams", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to update team", "error");
    },
  });

  // Delete Team Mutation
  const deleteTeamMutation = useMutation({
    mutationFn: async (id: string) => {
      await api.delete(`/teams/${id}`);
    },
    onSuccess: () => {
      showToast("Team deleted", "success");
      queryClient.invalidateQueries({ queryKey: ["teams", activeWorkspaceId] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-stats", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to delete team", "error");
    },
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[50vh]">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600" />
      </div>
    );
  }

  const handleCreateTeam = (e: React.FormEvent) => {
    e.preventDefault();
    if (!createName.trim()) return;
    createTeamMutation.mutate();
  };

  const handleSaveEdit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingTeam || !editName.trim()) return;
    updateTeamMutation.mutate({ id: editingTeam.id, name: editName, description: editDesc });
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      
      {/* Header */}
      <div className="flex items-center justify-between border-b border-gray-100 pb-5">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 font-inter">Teams</h1>
          <p className="text-xs text-gray-500 font-inter mt-1">Manage and scope your development teams under the active workspace.</p>
        </div>
        <button
          onClick={() => setShowCreateModal(true)}
          className="px-4 py-2 text-white bg-indigo-600 hover:bg-indigo-700 text-sm font-semibold rounded-lg font-inter flex items-center gap-2 shadow-xs cursor-pointer"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Create Team
        </button>
      </div>

      {/* Grid List */}
      {teams.length === 0 ? (
        <div className="bg-white rounded-xl shadow-xs p-12 text-center border border-gray-200 flex flex-col items-center">
          <svg className="h-16 w-16 text-gray-300 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
          <h3 className="text-sm font-bold text-gray-950 mb-1 font-inter">No teams yet</h3>
          <p className="text-xs text-gray-500 max-w-xs font-inter mb-4">Create your first team to start assigning projects and tasks.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {teams.map((t) => (
            <div
              key={t.id}
              className="bg-white rounded-xl shadow-xs border border-gray-200 p-5 flex flex-col justify-between hover:shadow-xs hover:border-indigo-300 transition-all min-h-36 group"
            >
              <div>
                <div className="flex items-start justify-between gap-4">
                  <div
                    onClick={() => navigate(`/teams/${t.id}`)}
                    className="flex items-center gap-2 cursor-pointer"
                  >
                    <div className="w-8 h-8 rounded-lg bg-indigo-50 border border-indigo-100 flex items-center justify-center font-extrabold text-indigo-600 font-inter text-sm">
                      {t.name.charAt(0).toUpperCase()}
                    </div>
                    <h3 className="font-bold text-sm text-gray-900 group-hover:text-indigo-600 transition-colors font-inter">
                      {t.name}
                    </h3>
                  </div>
                  <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button
                      onClick={() => {
                        setEditingTeam(t);
                        setEditName(t.name);
                        setEditDesc(t.description || "");
                      }}
                      className="text-gray-400 hover:text-indigo-600 transition-colors"
                    >
                      ✏️
                    </button>
                    <button
                      onClick={() => {
                        if (window.confirm("Are you sure you want to delete this team?")) {
                          deleteTeamMutation.mutate(t.id);
                        }
                      }}
                      className="text-gray-400 hover:text-red-600 transition-colors"
                    >
                      🗑️
                    </button>
                  </div>
                </div>
                <p className="text-xs text-gray-500 font-inter mt-3 line-clamp-2">
                  {t.description || "No description provided."}
                </p>
              </div>

              <div className="flex items-center justify-between border-t border-gray-50 pt-3 mt-4 text-[10px] text-gray-450 font-inter font-bold uppercase tracking-wider">
                <span className="bg-indigo-50 text-indigo-600 font-bold px-2 py-0.5 rounded-full lowercase font-inter">
                  {t._count?.projects ?? 0} projects
                </span>
                <span className="bg-slate-50 text-slate-600 font-bold px-2 py-0.5 rounded-full lowercase font-inter">
                  {t._count?.members ?? 0} members
                </span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Team Modal Form */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-md overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-gray-900 text-lg font-inter">Create Team</h3>
              <button onClick={() => setShowCreateModal(false)} className="text-gray-400 hover:text-gray-600 transition-colors">
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleCreateTeam} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Team Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Backend Engineers"
                  value={createName}
                  onChange={(e) => setCreateName(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Description</label>
                <textarea
                  placeholder="Focus areas and sprint velocity benchmarks..."
                  value={createDesc}
                  onChange={(e) => setCreateDesc(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 h-20"
                />
              </div>
              <div className="flex items-center justify-end gap-2 pt-2 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="px-4 py-2 border border-gray-300 hover:bg-gray-50 text-sm font-medium rounded-lg font-inter cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-lg font-inter transition-all cursor-pointer"
                >
                  Create
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Team Modal Form */}
      {editingTeam && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-md overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-gray-900 text-lg font-inter">Edit Team</h3>
              <button onClick={() => setEditingTeam(null)} className="text-gray-400 hover:text-gray-600 transition-colors">
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSaveEdit} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Team Name</label>
                <input
                  type="text"
                  required
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Description</label>
                <textarea
                  value={editDesc}
                  onChange={(e) => setEditDesc(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 h-20"
                />
              </div>
              <div className="flex items-center justify-end gap-2 pt-2 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setEditingTeam(null)}
                  className="px-4 py-2 border border-gray-300 hover:bg-gray-50 text-sm font-medium rounded-lg font-inter cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-lg font-inter transition-all cursor-pointer"
                >
                  Save
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
