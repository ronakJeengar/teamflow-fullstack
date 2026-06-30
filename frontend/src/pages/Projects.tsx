import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useToast } from "../context/useToast";
import { useProjects } from "../hooks/useProjects";
import { useTeams } from "../hooks/useTeams";
import type { Project } from "../types/Project";

export default function Projects() {
  const { activeWorkspaceId } = useWorkspace();
  const { showToast } = useToast();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const [editingProject, setEditingProject] = useState<Project | null>(null);
  const [editName, setEditName] = useState("");
  const [editColor, setEditColor] = useState("");

  const [showCreateModal, setShowCreateModal] = useState(false);
  const [createName, setCreateName] = useState("");
  const [createDesc, setCreateDesc] = useState("");
  const [createColor, setCreateColor] = useState("#4f46e5");
  const [createTeamId, setCreateTeamId] = useState("");

  // 1. Fetch Projects list scoped by activeWorkspaceId
  const { data: projects = [], isLoading } = useProjects(activeWorkspaceId);

  // 2. Fetch Teams for project creation targets
  const { data: teams = [] } = useTeams(activeWorkspaceId);

  const [selectedTeamTab, setSelectedTeamTab] = useState<string>("");

  const activeTabName = selectedTeamTab || (teams.length > 0 ? teams[0].name : "");

  const filteredProjects = activeTabName
    ? projects.filter((p) => p.team?.name?.toLowerCase() === activeTabName.toLowerCase())
    : projects;

  // Create Project Mutation
  const createProjectMutation = useMutation({
    mutationFn: async () => {
      if (!createTeamId) throw new Error("Team selection is required");
      await api.post(`/projects/${createTeamId}/create`, {
        name: createName,
        description: createDesc || null,
        color: createColor,
      });
    },
    onSuccess: () => {
      showToast("Project created successfully!", "success");
      setCreateName("");
      setCreateDesc("");
      setCreateColor("#4f46e5");
      setCreateTeamId("");
      setShowCreateModal(false);
      queryClient.invalidateQueries({ queryKey: ["projects", activeWorkspaceId] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-stats", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to create project", "error");
    },
  });

  // Update Project Mutation
  const updateProjectMutation = useMutation({
    mutationFn: async ({ id, name, color }: { id: string; name: string; color: string }) => {
      // Find teamId of the project to update
      const proj = projects.find((p) => p.id === id);
      if (!proj) throw new Error("Project not found");
      await api.patch(`/projects/${proj.teamId}/${id}`, { name, color });
    },
    onSuccess: () => {
      showToast("Project updated successfully!", "success");
      setEditingProject(null);
      queryClient.invalidateQueries({ queryKey: ["projects", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to update project", "error");
    },
  });

  // Delete Project Mutation
  const deleteProjectMutation = useMutation({
    mutationFn: async (id: string) => {
      const proj = projects.find((p) => p.id === id);
      if (!proj) throw new Error("Project not found");
      await api.delete(`/projects/${proj.teamId}/${id}`);
    },
    onSuccess: () => {
      showToast("Project deleted", "success");
      queryClient.invalidateQueries({ queryKey: ["projects", activeWorkspaceId] });
      queryClient.invalidateQueries({ queryKey: ["dashboard-stats", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to delete project", "error");
    },
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[50vh]">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600" />
      </div>
    );
  }

  const handleCreateProject = (e: React.FormEvent) => {
    e.preventDefault();
    if (!createName.trim() || !createTeamId) return;
    createProjectMutation.mutate();
  };

  const handleSaveEdit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingProject || !editName.trim()) return;
    updateProjectMutation.mutate({ id: editingProject.id, name: editName, color: editColor });
  };

  const colors = ["#4f46e5", "#06b6d4", "#10b981", "#f59e0b", "#ef4444", "#ec4899", "#8b5cf6"];

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      
      {/* Header */}
      <div className="flex items-center justify-between border-b border-gray-100 pb-5">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 font-inter">Projects</h1>
          <p className="text-xs text-gray-500 font-inter mt-1">Manage, update, or create projects in the current workspace.</p>
        </div>
        <button
          onClick={() => {
            if (teams.length === 0) {
              showToast("Please create a Team first before creating a Project", "error");
              return;
            }
            // Auto select first team
            setCreateTeamId(teams[0].id);
            setShowCreateModal(true);
          }}
          className="px-4 py-2 text-white bg-indigo-600 hover:bg-indigo-700 text-sm font-semibold rounded-lg font-inter flex items-center gap-2 shadow-xs cursor-pointer"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Create Project
        </button>
      </div>

      {/* Scrollable Team Tabs */}
      {teams.length > 0 && (
        <div className="flex border-b border-gray-150 overflow-x-auto text-[10px] font-bold text-gray-500 uppercase tracking-wide shrink-0">
          {teams.map((t) => {
            const isSel = activeTabName.toLowerCase() === t.name.toLowerCase();
            const count = projects.filter((p) => p.teamId === t.id).length;
            return (
              <button
                key={t.id}
                onClick={() => setSelectedTeamTab(t.name)}
                className={`px-3 py-1.5 border-b-2 -mb-px transition-colors cursor-pointer shrink-0 font-inter ${
                  isSel
                    ? "border-indigo-600 text-indigo-600 font-bold"
                    : "border-transparent hover:text-gray-900"
                }`}
              >
                {t.name} ({count})
              </button>
            );
          })}
        </div>
      )}

      {/* Grid List */}
      {filteredProjects.length === 0 ? (
        <div className="bg-white rounded-xl shadow-xs p-12 text-center border border-gray-200 flex flex-col items-center">
          <svg className="h-16 w-16 text-gray-300 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <h3 className="text-sm font-bold text-gray-950 mb-1 font-inter">No projects found</h3>
          <p className="text-xs text-gray-500 max-w-xs font-inter mb-4">No projects have been created under this team tab yet.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredProjects.map((p) => (
            <div
              key={p.id}
              className="bg-white rounded-xl shadow-xs border border-gray-200 p-5 flex flex-col justify-between hover:shadow-xs hover:border-indigo-300 transition-all min-h-36 group"
            >
              <div>
                <div className="flex items-start justify-between gap-4">
                  <div
                    onClick={() => navigate(`/projects/${p.id}`)}
                    className="flex items-center gap-2 cursor-pointer"
                  >
                    <span className="w-3.5 h-3.5 rounded-full border border-black/5" style={{ backgroundColor: p.color || "#4f46e5" }} />
                    <h3 className="font-bold text-sm text-gray-900 group-hover:text-indigo-600 transition-colors font-inter">
                      {p.name}
                    </h3>
                  </div>
                  <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                    <button
                      onClick={() => {
                        setEditingProject(p);
                        setEditName(p.name);
                        setEditColor(p.color || "#4f46e5");
                      }}
                      className="text-gray-400 hover:text-indigo-600 transition-colors"
                    >
                      ✏️
                    </button>
                    <button
                      onClick={() => {
                        if (window.confirm("Are you sure you want to delete this project?")) {
                          deleteProjectMutation.mutate(p.id);
                        }
                      }}
                      className="text-gray-400 hover:text-red-600 transition-colors"
                    >
                      🗑️
                    </button>
                  </div>
                </div>
                <p className="text-xs text-gray-500 font-inter mt-1.5 line-clamp-2">
                  {p.description || "No description provided."}
                </p>
              </div>

              <div className="flex items-center justify-between border-t border-gray-50 pt-3 mt-4 text-[10px] text-gray-400 font-inter uppercase tracking-wider font-bold">
                <span>Team: {p.team?.name || "N/A"}</span>
                <span className="bg-indigo-50 text-indigo-600 font-bold px-2 py-0.5 rounded-full lowercase font-inter">
                  {p._count?.tasks ?? 0} tasks
                </span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Project Modal Form */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-md overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-gray-900 text-lg font-inter">Create Project</h3>
              <button onClick={() => setShowCreateModal(false)} className="text-gray-400 hover:text-gray-600 transition-colors">
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleCreateProject} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Project Name</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. API Gateway"
                  value={createName}
                  onChange={(e) => setCreateName(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Description</label>
                <textarea
                  placeholder="Describe project outcomes..."
                  value={createDesc}
                  onChange={(e) => setCreateDesc(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 h-20"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Assign Team</label>
                <select
                  value={createTeamId}
                  onChange={(e) => setCreateTeamId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
                >
                  {teams.map((t) => (
                    <option key={t.id} value={t.id}>{t.name}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-2 font-inter">Color Tag</label>
                <div className="flex items-center gap-2 flex-wrap">
                  {colors.map((c) => (
                    <button
                      key={c}
                      type="button"
                      onClick={() => setCreateColor(c)}
                      style={{ backgroundColor: c }}
                      className={`w-8 h-8 rounded-full border-2 transition-all ${
                        createColor === c ? "border-gray-900 scale-110 shadow-sm" : "border-transparent hover:scale-105"
                      }`}
                    />
                  ))}
                </div>
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

      {/* Edit Project Modal Form */}
      {editingProject && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-md overflow-hidden animate-in fade-in zoom-in-95 duration-150">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-gray-900 text-lg font-inter">Edit Project</h3>
              <button onClick={() => setEditingProject(null)} className="text-gray-400 hover:text-gray-600 transition-colors">
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <form onSubmit={handleSaveEdit} className="p-6 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Project Name</label>
                <input
                  type="text"
                  required
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-2 font-inter">Color Tag</label>
                <div className="flex items-center gap-2 flex-wrap">
                  {colors.map((c) => (
                    <button
                      key={c}
                      type="button"
                      onClick={() => setEditColor(c)}
                      style={{ backgroundColor: c }}
                      className={`w-8 h-8 rounded-full border-2 transition-all ${
                        editColor === c ? "border-gray-900 scale-110 shadow-sm" : "border-transparent hover:scale-105"
                      }`}
                    />
                  ))}
                </div>
              </div>
              <div className="flex items-center justify-end gap-2 pt-2 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setEditingProject(null)}
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
