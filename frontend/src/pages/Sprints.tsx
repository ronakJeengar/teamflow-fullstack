import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useToast } from "../context/useToast";
import type { Sprint } from "../types/Sprint";
import type { Task } from "../types/Task";
import type { Team } from "../types/Team";

export default function Sprints() {
  const { teamId } = useParams<{ teamId: string }>();
  const { activeWorkspaceId } = useWorkspace();
  const { showToast } = useToast();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  // Selected Sprint for Backlog Planning assignment
  const [selectedSprintId, setSelectedSprintId] = useState<string>("");

  // Create Sprint Form State
  const [sprintName, setSprintName] = useState("");
  const [sprintGoal, setSprintGoal] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [showCreateForm, setShowCreateForm] = useState(false);

  // 1. Fetch current team details
  const { data: team, isLoading: teamLoading } = useQuery<Team>({
    queryKey: ["team", teamId],
    queryFn: async () => {
      const res = await api.get(`/teams/${teamId}`);
      return res.data?.data;
    },
    enabled: !!teamId,
  });

  // 2. Fetch sprints of the team
  const { data: sprints = [], isLoading: sprintsLoading } = useQuery<Sprint[]>({
    queryKey: ["team-sprints", teamId],
    queryFn: async () => {
      const res = await api.get("/sprints", {
        params: { teamId, workspaceId: activeWorkspaceId },
      });
      const items: Sprint[] = res.data?.data ?? [];
      // Set initial selected sprint to the active or latest planned one
      if (items.length > 0 && !selectedSprintId) {
        const active = items.find((s) => s.status === "ACTIVE") || items.find((s) => s.status === "PLANNED") || items[0];
        setSelectedSprintId(active.id);
      }
      return items;
    },
    enabled: !!teamId && !!activeWorkspaceId,
  });

  // 3. Fetch all tasks in the team's projects
  const { data: teamTasks = [], isLoading: tasksLoading } = useQuery<Task[]>({
    queryKey: ["team-tasks", teamId],
    queryFn: async () => {
      const projRes = await api.get("/projects", {
        params: { teamId, workspaceId: activeWorkspaceId },
      });
      const projects = projRes.data?.data ?? [];
      
      const allTasks: Task[] = [];
      for (const p of projects) {
        try {
          const taskRes = await api.get(`/tasks/project/${p.id}`);
          const items = taskRes.data?.data?.items ?? [];
          allTasks.push(...items);
        } catch (e) {
          console.warn("Failed to load tasks for project:", p.id, e);
        }
      }
      return allTasks;
    },
    enabled: !!teamId && !!activeWorkspaceId,
  });

  // Create Sprint Mutation
  const createSprintMutation = useMutation({
    mutationFn: async () => {
      await api.post("/sprints", {
        name: sprintName,
        goal: sprintGoal || null,
        startDate: startDate || null,
        endDate: endDate || null,
        teamId,
        workspaceId: activeWorkspaceId,
      });
    },
    onSuccess: () => {
      showToast("Sprint created successfully!", "success");
      setSprintName("");
      setSprintGoal("");
      setStartDate("");
      setEndDate("");
      setShowCreateForm(false);
      queryClient.invalidateQueries({ queryKey: ["team-sprints", teamId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to create sprint", "error");
    },
  });

  // Start Sprint Mutation
  const startSprintMutation = useMutation({
    mutationFn: async (id: string) => {
      await api.post(`/sprints/${id}/start`);
    },
    onSuccess: () => {
      showToast("Sprint started successfully!", "success");
      queryClient.invalidateQueries({ queryKey: ["team-sprints", teamId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to start sprint", "error");
    },
  });

  // Complete Sprint Mutation
  const completeSprintMutation = useMutation({
    mutationFn: async (id: string) => {
      await api.post(`/sprints/${id}/complete`);
    },
    onSuccess: () => {
      showToast("Sprint completed successfully!", "success");
      queryClient.invalidateQueries({ queryKey: ["team-sprints", teamId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to complete sprint", "error");
    },
  });

  // Cancel Sprint Mutation
  const cancelSprintMutation = useMutation({
    mutationFn: async (id: string) => {
      await api.post(`/sprints/${id}/cancel`);
    },
    onSuccess: () => {
      showToast("Sprint cancelled successfully!", "success");
      queryClient.invalidateQueries({ queryKey: ["team-sprints", teamId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to cancel sprint", "error");
    },
  });

  // Assign Task to Sprint Mutation
  const assignToSprintMutation = useMutation({
    mutationFn: async ({ sprintId, taskId }: { sprintId: string; taskId: string }) => {
      await api.post(`/sprints/${sprintId}/tasks`, { taskId });
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["team-tasks", teamId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to assign task", "error");
    },
  });

  // Remove Task from Sprint Mutation
  const removeFromSprintMutation = useMutation({
    mutationFn: async ({ sprintId, taskId }: { sprintId: string; taskId: string }) => {
      await api.delete(`/sprints/${sprintId}/tasks/${taskId}`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["team-tasks", teamId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to remove task", "error");
    },
  });

  if (teamLoading || sprintsLoading || tasksLoading) {
    return (
      <div className="flex items-center justify-center min-h-[50vh]">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600" />
      </div>
    );
  }

  const backlogTasks = teamTasks.filter((t) => t.isBacklog || !t.sprintId);
  const sprintTasks = teamTasks.filter((t) => t.sprintId === selectedSprintId);
  const totalSprintStoryPoints = sprintTasks.reduce((sum, t) => sum + (t.storyPoints || 0), 0);

  const CAPACITY_LIMIT = 40;
  const isOverCapacity = totalSprintStoryPoints > CAPACITY_LIMIT;

  return (
    <div className="space-y-8 animate-in fade-in duration-200">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-gray-100 pb-5">
        <div>
          <div className="flex items-center gap-2">
            <button
              onClick={() => navigate(`/teams/${teamId}`)}
              className="p-1.5 hover:bg-gray-100 border border-gray-200 rounded-lg text-gray-600 transition-colors"
            >
              <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <h1 className="text-2xl font-bold text-gray-900 font-inter">{team?.name} — Sprint Hub</h1>
          </div>
          <p className="text-xs text-gray-500 font-inter mt-1">Manage team sprints, velocities, and plan backlog grooming splits.</p>
        </div>
        <button
          onClick={() => setShowCreateForm(!showCreateForm)}
          className="px-4 py-2 text-white bg-indigo-600 hover:bg-indigo-700 text-sm font-semibold rounded-lg font-inter flex items-center gap-2 transition-all cursor-pointer shadow-xs"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          New Sprint
        </button>
      </div>

      {/* Create Sprint Panel */}
      {showCreateForm && (
        <form
          onSubmit={(e) => {
            e.preventDefault();
            createSprintMutation.mutate();
          }}
          className="p-6 bg-white border border-gray-200 rounded-xl shadow-xs grid grid-cols-1 md:grid-cols-2 gap-4 animate-in slide-in-from-top-3 duration-250"
        >
          <div>
            <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Sprint Name</label>
            <input
              type="text"
              required
              placeholder="e.g. Sprint 24 — Core Improvements"
              value={sprintName}
              onChange={(e) => setSprintName(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Sprint Goal</label>
            <input
              type="text"
              placeholder="e.g. Implement backend query optimization"
              value={sprintGoal}
              onChange={(e) => setSprintGoal(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Start Date</label>
            <input
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">End Date</label>
            <input
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
            />
          </div>
          <div className="md:col-span-2 flex items-center justify-end gap-2 pt-2 border-t border-gray-100">
            <button
              type="button"
              onClick={() => setShowCreateForm(false)}
              className="px-4 py-2 border border-gray-300 hover:bg-gray-50 text-sm font-medium rounded-lg font-inter cursor-pointer"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold rounded-lg font-inter transition-all cursor-pointer"
            >
              Create Sprint
            </button>
          </div>
        </form>
      )}

      {/* Sprints Overview List */}
      <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-xs">
        <h3 className="font-bold text-gray-900 text-sm tracking-wide font-inter mb-4">Sprints Timeline</h3>
        {sprints.length === 0 ? (
          <div className="py-6 text-center text-xs text-gray-400 font-semibold font-inter">
            No sprints created for this team. Create a sprint to start planning.
          </div>
        ) : (
          <div className="space-y-4">
            {sprints.map((s) => (
              <div key={s.id} className="p-4 border border-gray-100 bg-gray-50/50 rounded-xl flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h4 className="font-bold text-xs text-gray-900 font-inter">{s.name}</h4>
                    <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase leading-none ${
                      s.status === "ACTIVE"
                        ? "bg-indigo-100 text-indigo-700"
                        : s.status === "COMPLETED"
                          ? "bg-emerald-100 text-emerald-700"
                          : s.status === "CANCELLED"
                            ? "bg-rose-100 text-rose-700"
                            : "bg-slate-100 text-slate-700"
                    }`}>
                      {s.status}
                    </span>
                  </div>
                  <p className="text-[11px] text-gray-555 font-inter">{s.goal || "No goal specified"}</p>
                  <p className="text-[10px] text-gray-400 font-inter">
                    {s.startDate ? new Date(s.startDate).toLocaleDateString() : "No start date"} - {s.endDate ? new Date(s.endDate).toLocaleDateString() : "No end date"}
                  </p>
                </div>
                
                <div className="flex items-center gap-2">
                  {s.status === "PLANNED" && (
                    <button
                      onClick={() => startSprintMutation.mutate(s.id)}
                      className="px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-xs font-bold text-white rounded-lg font-inter cursor-pointer transition-all"
                    >
                      Start Sprint
                    </button>
                  )}
                  {s.status === "ACTIVE" && (
                    <>
                      <button
                        onClick={() => completeSprintMutation.mutate(s.id)}
                        className="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-xs font-bold text-white rounded-lg font-inter cursor-pointer transition-all"
                      >
                        Complete
                      </button>
                      <button
                        onClick={() => cancelSprintMutation.mutate(s.id)}
                        className="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-xs font-bold text-rose-600 rounded-lg font-inter cursor-pointer transition-all border border-rose-100"
                      >
                        Cancel
                      </button>
                    </>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Split Pane: Backlog vs Selected Sprint Assignment */}
      {sprints.length > 0 && (
        <div className="space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-4 border border-gray-200 rounded-xl shadow-xs">
            <h3 className="font-bold text-gray-900 text-sm font-inter">Sprint Backlog Grooming</h3>
            <div className="flex items-center gap-2">
              <span className="text-xs text-gray-500 font-semibold font-inter">Target Sprint:</span>
              <select
                value={selectedSprintId}
                onChange={(e) => setSelectedSprintId(e.target.value)}
                className="px-3 py-1.5 border border-gray-300 rounded-lg text-xs font-bold font-inter bg-white focus:outline-hidden"
              >
                {sprints.map((s) => (
                  <option key={s.id} value={s.id}>{s.name} ({s.status})</option>
                ))}
              </select>
            </div>
          </div>

          {/* Warning Banner */}
          {isOverCapacity && (
            <div className="p-4 bg-amber-50 border border-amber-200 rounded-xl text-amber-800 text-xs font-semibold flex items-center gap-2 animate-pulse font-inter">
              <svg className="w-5 h-5 text-amber-500 shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
              </svg>
              Warning: Selected sprint capacity ({totalSprintStoryPoints} SP) exceeds recommendations ({CAPACITY_LIMIT} SP limit). Consider moving tasks to Backlog.
            </div>
          )}

          {/* Splits Grid */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            
            {/* Left split pane: Team Backlog */}
            <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-xs flex flex-col h-[500px]">
              <div className="border-b border-gray-100 pb-3 mb-4 flex items-center justify-between shrink-0">
                <h4 className="font-bold text-gray-900 text-xs tracking-wider uppercase font-inter">Team Backlog ({backlogTasks.length})</h4>
                <span className="text-[10px] bg-slate-100 text-slate-500 font-bold px-2 py-0.5 rounded-full font-inter">
                  Ready to Assign
                </span>
              </div>
              <div className="flex-1 overflow-y-auto space-y-3 pr-1">
                {backlogTasks.length === 0 ? (
                  <div className="py-12 text-center text-xs text-gray-400 font-semibold font-inter">
                    Grooming complete! No backlog tasks left.
                  </div>
                ) : (
                  backlogTasks.map((t) => (
                    <div key={t.id} className="p-3 border border-gray-100 hover:border-gray-200 bg-gray-50/50 rounded-lg flex items-center justify-between gap-4">
                      <div>
                        <p className="text-xs font-bold text-gray-900 font-inter">{t.title}</p>
                        <div className="flex items-center gap-2 mt-1">
                          <span className="text-[9px] bg-indigo-50 text-indigo-600 font-bold px-1 rounded-sm font-inter">
                            {t.storyPoints || 0} SP
                          </span>
                          <span className="text-[9px] text-gray-400 font-inter">ID: {t.id}</span>
                        </div>
                      </div>
                      <button
                        onClick={() => assignToSprintMutation.mutate({ sprintId: selectedSprintId, taskId: t.id })}
                        className="px-2.5 py-1 text-[11px] font-bold text-indigo-600 hover:bg-indigo-50 border border-indigo-100 hover:border-indigo-200 rounded-md cursor-pointer transition-all"
                      >
                        Assign
                      </button>
                    </div>
                  ))
                )}
              </div>
            </div>

            {/* Right split pane: Selected Sprint tasks */}
            <div className="bg-white border border-gray-200 rounded-xl p-6 shadow-xs flex flex-col h-[500px]">
              <div className="border-b border-gray-100 pb-3 mb-4 flex items-center justify-between shrink-0">
                <div className="space-y-0.5">
                  <h4 className="font-bold text-gray-900 text-xs tracking-wider uppercase font-inter">Sprint Tasks ({sprintTasks.length})</h4>
                  <p className="text-[10px] text-gray-400 font-inter">Sprint capacity: {totalSprintStoryPoints} Story Points</p>
                </div>
                <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full font-inter ${
                  isOverCapacity ? "bg-red-50 text-red-600" : "bg-emerald-50 text-emerald-600"
                }`}>
                  {totalSprintStoryPoints} SP Assigned
                </span>
              </div>
              <div className="flex-1 overflow-y-auto space-y-3 pr-1">
                {sprintTasks.length === 0 ? (
                  <div className="py-12 text-center text-xs text-gray-400 font-semibold font-inter">
                    Backlog is empty. Assign tasks from the left panel.
                  </div>
                ) : (
                  sprintTasks.map((t) => (
                    <div key={t.id} className="p-3 border border-gray-100 hover:border-indigo-100 bg-indigo-50/5 rounded-lg flex items-center justify-between gap-4">
                      <div>
                        <p className="text-xs font-bold text-gray-900 font-inter">{t.title}</p>
                        <div className="flex items-center gap-2 mt-1">
                          <span className="text-[9px] bg-indigo-100 text-indigo-700 font-bold px-1 rounded-sm font-inter">
                            {t.storyPoints || 0} SP
                          </span>
                          <span className="text-[9px] text-gray-400 font-inter">ID: {t.id}</span>
                        </div>
                      </div>
                      <button
                        onClick={() => removeFromSprintMutation.mutate({ sprintId: selectedSprintId, taskId: t.id })}
                        className="px-2.5 py-1 text-[11px] font-bold text-red-600 hover:bg-red-50 border border-red-100 hover:border-red-200 rounded-md cursor-pointer transition-all"
                      >
                        Remove
                      </button>
                    </div>
                  ))
                )}
              </div>
            </div>

          </div>
        </div>
      )}

    </div>
  );
}
