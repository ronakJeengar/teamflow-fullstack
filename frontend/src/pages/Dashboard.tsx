import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Link, useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useProjects } from "../hooks/useProjects";
import type { Task } from "../types/Task";
import type { Activity } from "../types/Activity";

export default function Dashboard() {
  const { activeWorkspaceId, activeWorkspace } = useWorkspace();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<"Assigned" | "In Progress" | "Upcoming" | "Overdue" | "Completed">("Assigned");

  // 1. Fetch dashboard metrics & sprint stats
  const { data: stats, isLoading: statsLoading } = useQuery({
    queryKey: ["dashboard-stats", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return null;
      const res = await api.get("/stats/dashboard", {
        params: { workspaceId: activeWorkspaceId },
      });
      return res.data?.data;
    },
    enabled: !!activeWorkspaceId,
  });

  // 2. Fetch my work tasks
  const { data: myTasks = [] } = useQuery<Task[]>({
    queryKey: ["my-tasks", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      const res = await api.get("/tasks/my");
      // filter tasks by active workspace
      const allTasks: Task[] = res.data?.data ?? [];
      return allTasks.filter(
        (t: any) => t.project?.team?.workspaceId === activeWorkspaceId
      );
    },
    enabled: !!activeWorkspaceId,
  });

  // 3. Fetch recent projects
  const { data: projects = [], isLoading: projectsLoading } = useProjects(activeWorkspaceId);

  // 4. Fetch activity feed
  const { data: activities = [], isLoading: activitiesLoading } = useQuery<Activity[]>({
    queryKey: ["activities", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      // Fetch activity logs for projects in workspace
      const allActivities: Activity[] = [];
      for (const p of projects) {
        try {
          const res = await api.get(`/activities/projects/${p.id}`);
          allActivities.push(...(res.data?.data ?? []));
        } catch (e) {
          // ignore project activities load errors
        }
      }
      return allActivities.sort(
        (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      );
    },
    enabled: !!activeWorkspaceId && projects.length > 0,
  });

  if (!activeWorkspaceId) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] bg-white rounded-xl shadow-xs border border-gray-100 p-8 text-center animate-in fade-in duration-300">
        <svg className="w-16 h-16 text-indigo-500 mb-4 animate-bounce" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
        </svg>
        <h2 className="text-xl font-bold text-gray-900 mb-2 font-inter">Welcome to TeamFlow!</h2>
        <p className="text-gray-500 text-sm max-w-sm font-inter">
          Please select or create a workspace from the top-left switcher to load your team flow dashboard.
        </p>
      </div>
    );
  }

  const priorityColors: Record<string, string> = {
    LOW: "bg-gray-100 text-gray-700 border-gray-200",
    MEDIUM: "bg-blue-50 text-blue-700 border-blue-100",
    HIGH: "bg-orange-50 text-orange-700 border-orange-100",
    URGENT: "bg-red-100 text-red-700 border-red-200 animate-pulse",
  };

  const statusColors: Record<string, string> = {
    TODO: "bg-slate-100 text-slate-700",
    IN_PROGRESS: "bg-indigo-50 text-indigo-700",
    REVIEW: "bg-amber-50 text-amber-700",
    BLOCKED: "bg-rose-50 text-rose-700",
    DONE: "bg-emerald-50 text-emerald-700",
  };

  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const todayEnd = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);

  const getFilteredTasks = () => {
    return myTasks.filter((t) => {
      if (activeTab === "Assigned") return true;
      if (activeTab === "In Progress") return t.status === "IN_PROGRESS";
      if (activeTab === "Upcoming") {
        if (t.status === "DONE") return false;
        if (!t.dueDate) return false;
        return new Date(t.dueDate) > todayEnd;
      }
      if (activeTab === "Overdue") {
        if (t.status === "DONE") return false;
        if (!t.dueDate) return false;
        return new Date(t.dueDate) < todayStart;
      }
      if (activeTab === "Completed") return t.status === "DONE";
      return true;
    });
  };

  const getCount = (tab: "Assigned" | "In Progress" | "Upcoming" | "Overdue" | "Completed") => {
    return myTasks.filter((t) => {
      if (tab === "Assigned") return true;
      if (tab === "In Progress") return t.status === "IN_PROGRESS";
      if (tab === "Upcoming") {
        if (t.status === "DONE") return false;
        if (!t.dueDate) return false;
        return new Date(t.dueDate) > todayEnd;
      }
      if (tab === "Overdue") {
        if (t.status === "DONE") return false;
        if (!t.dueDate) return false;
        return new Date(t.dueDate) < todayStart;
      }
      if (tab === "Completed") return t.status === "DONE";
      return true;
    }).length;
  };

  const filteredTasks = getFilteredTasks();

  return (
    <div className="animate-in fade-in duration-300">
      
      {/* ──────────────────────────────────────────────────────── */}
      {/* DESKTOP LAYOUT (hidden lg:block) */}
      {/* ──────────────────────────────────────────────────────── */}
      <div className="hidden lg:block space-y-8">
        {/* Workspace Metric Banner */}
        <div
          className="rounded-2xl shadow-sm border border-black/5 p-8 relative overflow-hidden flex flex-col justify-end min-h-[160px] text-white transition-all duration-300"
          style={{
            background: `linear-gradient(135deg, ${activeWorkspace?.color || "#4f46e5"}cc, ${activeWorkspace?.color || "#4f46e5"})`,
          }}
        >
          <div className="absolute top-0 right-0 p-8 opacity-10">
            <svg className="w-32 h-32" fill="currentColor" viewBox="0 0 24 24">
              <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z" />
            </svg>
          </div>
          <div className="relative z-10 space-y-4">
            <div>
              <h1 className="text-3xl font-extrabold font-inter tracking-tight">{activeWorkspace?.name}</h1>
              <p className="text-white/80 text-xs font-semibold font-inter mt-1">Workspace Isolation Enabled</p>
            </div>
            <div className="flex flex-wrap gap-4 items-center border-t border-white/20 pt-4 text-xs font-bold uppercase tracking-wider font-inter">
              <div className="px-3 py-1.5 bg-white/10 rounded-lg backdrop-blur-xs">
                Teams: {stats?.team_count ?? 0}
              </div>
              <div className="px-3 py-1.5 bg-white/10 rounded-lg backdrop-blur-xs">
                Projects: {stats?.project_count ?? 0}
              </div>
              <div className="px-3 py-1.5 bg-white/10 rounded-lg backdrop-blur-xs">
                Members: {stats?.member_count ?? 0}
              </div>
              <div className="px-3 py-1.5 bg-white/10 rounded-lg backdrop-blur-xs">
                Tasks: {stats?.task_count ?? 0}
              </div>
            </div>
          </div>
        </div>

        {/* Grid Layout Dashboard Widgets */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left column (Sprint Health & Recent Projects) */}
          <div className="lg:col-span-2 space-y-8">
            {/* Sprint Health Widget */}
            <div className="bg-white rounded-xl shadow-xs border border-gray-200 p-6">
              <div className="flex items-center justify-between mb-4 border-b border-gray-100 pb-3">
                <h3 className="font-bold text-gray-900 text-sm tracking-wide font-inter">Sprint Health</h3>
                {stats?.currentSprint && (
                  <span className="text-xs bg-indigo-50 text-indigo-600 font-bold px-2 py-0.5 rounded-full font-inter">
                    Active
                  </span>
                )}
              </div>
              {statsLoading ? (
                <div className="py-4 text-center text-xs text-gray-500 font-inter">Loading sprint details...</div>
              ) : stats?.currentSprint ? (
                <div className="space-y-4">
                  <div>
                    <h4 className="text-sm font-bold text-gray-900 font-inter">{stats.currentSprint.name}</h4>
                    <p className="text-xs text-gray-500 font-inter mt-1">{stats.currentSprint.goal || "No sprint goal defined."}</p>
                  </div>
                  
                  {/* Progress bar */}
                  <div className="space-y-1">
                    <div className="flex items-center justify-between text-xs font-semibold text-gray-600 font-inter">
                      <span>Task Completion</span>
                      <span>{stats.sprintProgress?.completionPercentage}%</span>
                    </div>
                    <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-indigo-600 rounded-full transition-all duration-500"
                        style={{ width: `${stats.sprintProgress?.completionPercentage}%` }}
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-4 border-t border-gray-100 pt-4 text-center">
                    <div>
                      <span className="block text-[10px] font-semibold text-gray-400 uppercase tracking-wider font-inter">Completed Tasks</span>
                      <span className="text-lg font-bold text-gray-800 font-inter">{stats.sprintProgress?.completedTasks} / {stats.sprintProgress?.totalTasks}</span>
                    </div>
                    <div>
                      <span className="block text-[10px] font-semibold text-gray-400 uppercase tracking-wider font-inter">Sprint Velocity</span>
                      <span className="text-lg font-bold text-indigo-600 font-inter">{stats.sprintVelocity} SP</span>
                    </div>
                    <div>
                      <span className="block text-[10px] font-semibold text-gray-400 uppercase tracking-wider font-inter">End Date</span>
                      <span className="text-sm font-bold text-gray-700 font-inter">
                        {stats.currentSprint.endDate ? new Date(stats.currentSprint.endDate).toLocaleDateString() : "N/A"}
                      </span>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="py-6 text-center text-xs text-gray-400 font-semibold font-inter">
                  No active sprint in this workspace. Start a sprint from a Team's board to view analytics.
                </div>
              )}
            </div>

            {/* Recent Projects Widget */}
            <div className="bg-white rounded-xl shadow-xs border border-gray-200 p-6">
              <div className="flex items-center justify-between mb-4 border-b border-gray-100 pb-3">
                <h3 className="font-bold text-gray-900 text-sm tracking-wide font-inter">Recent Projects</h3>
                <Link to="/projects" className="text-xs text-indigo-600 font-bold hover:underline font-inter">
                  View all projects
                </Link>
              </div>
              {projectsLoading ? (
                <div className="py-4 text-center text-xs text-gray-500 font-inter">Loading projects...</div>
              ) : projects.length === 0 ? (
                <div className="py-6 text-center text-xs text-gray-400 font-semibold font-inter">
                  No projects created yet. Create a project to get started.
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {projects.slice(0, 4).map((p) => (
                    <div
                      key={p.id}
                      onClick={() => navigate(`/projects/${p.id}`)}
                      className="p-4 border border-gray-200 hover:border-indigo-500 hover:shadow-xs rounded-xl transition-all cursor-pointer bg-gray-50/50 flex flex-col justify-between h-28"
                    >
                      <div>
                        <div className="flex items-center gap-2">
                          <span className="w-3 h-3 rounded-full border border-black/5" style={{ backgroundColor: p.color || "#6366f1" }} />
                          <h4 className="text-xs font-bold text-gray-900 truncate font-inter">{p.name}</h4>
                        </div>
                        <p className="text-[10px] text-gray-500 mt-1 line-clamp-2 font-inter">{p.description || "No description provided."}</p>
                      </div>
                      <div className="flex items-center justify-between border-t border-gray-100 pt-2 mt-2">
                        <span className="text-[9px] text-gray-400 font-bold uppercase tracking-wider font-inter">
                          {p.visibility}
                        </span>
                        <span className="text-[10px] bg-indigo-50 text-indigo-600 font-bold px-2 py-0.5 rounded-full font-inter">
                          Tasks: {p._count?.tasks ?? 0}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Right column (My Work tasks list & Activity Feed) */}
          <div className="space-y-8">
            {/* My Work Widget */}
            <div className="bg-white rounded-xl shadow-xs border border-gray-200 p-6 flex flex-col max-h-[450px]">
              <div className="flex items-center justify-between mb-2 shrink-0">
                <h3 className="font-bold text-gray-900 text-sm tracking-wide font-inter">My Work</h3>
                <span className="text-xs bg-slate-100 text-slate-600 font-bold px-2 py-0.5 rounded-full font-inter">
                  {filteredTasks.length} {activeTab}
                </span>
              </div>

              {/* Scrollable Tabs */}
              <div className="flex border-b border-gray-150 mb-3 overflow-x-auto text-[10px] font-bold text-gray-500 uppercase tracking-wide shrink-0">
                {(["Assigned", "In Progress", "Upcoming", "Overdue", "Completed"] as const).map((tab) => (
                  <button
                    key={tab}
                    onClick={() => setActiveTab(tab)}
                    className={`px-3 py-1.5 border-b-2 -mb-px transition-colors cursor-pointer shrink-0 font-inter ${
                      activeTab === tab
                        ? "border-indigo-600 text-indigo-600 font-bold"
                        : "border-transparent hover:text-gray-900"
                    }`}
                  >
                    {tab} ({getCount(tab)})
                  </button>
                ))}
              </div>

              {/* Task Items list container */}
              <div className="flex-1 overflow-y-auto divide-y divide-gray-100 pr-1">
                {filteredTasks.length === 0 ? (
                  <div className="py-12 text-center text-xs text-gray-400 font-inter font-semibold">
                    You have no tasks in this category. 🎉
                  </div>
                ) : (
                  filteredTasks.map((t) => (
                    <div
                      key={t.id}
                      onClick={() => navigate(`/projects/${t.projectId}`)}
                      className="py-3 flex items-center justify-between gap-4 group cursor-pointer hover:bg-slate-50/50 rounded-lg px-2 transition-all"
                    >
                      <div className="min-w-0 flex-1">
                        <p className="font-bold text-xs text-gray-900 truncate font-inter group-hover:text-indigo-600 transition-colors">
                          {t.title}
                        </p>
                        <p className="text-[10px] text-gray-500 truncate font-inter mt-0.5">
                          Project: {(t as any).project?.name || "Global"}
                        </p>
                      </div>
                      <div className="flex items-center gap-2 shrink-0">
                        {t.priority && (
                          <span className={`text-[9px] font-bold px-1.5 py-0.5 rounded-md border font-inter uppercase ${priorityColors[t.priority]}`}>
                            {t.priority}
                          </span>
                        )}
                        <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full font-inter uppercase ${statusColors[t.status]}`}>
                          {t.status.replace("_", " ")}
                        </span>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>

            {/* Activity Feed Widget */}
            <div className="bg-white rounded-xl shadow-xs border border-gray-200 p-6 flex flex-col max-h-[350px]">
              <div className="flex items-center justify-between mb-4 border-b border-gray-100 pb-3 shrink-0">
                <h3 className="font-bold text-gray-900 text-sm tracking-wide font-inter">Workspace Activity</h3>
              </div>
              {activitiesLoading ? (
                <div className="py-4 text-center text-xs text-gray-500 font-inter">Loading activities...</div>
              ) : activities.length === 0 ? (
                <div className="py-6 text-center text-xs text-gray-400 font-semibold font-inter">
                  No activity logged in this workspace yet.
                </div>
              ) : (
                <div className="flex-1 overflow-y-auto space-y-3.5 pr-1">
                  {activities.slice(0, 10).map((act) => (
                    <div key={act.id} className="flex gap-3 text-xs leading-normal">
                      <div className="w-6 h-6 rounded-full bg-slate-100 border border-slate-200 text-slate-700 font-bold flex items-center justify-center text-[10px] shrink-0 font-inter">
                        {act.user?.name?.charAt(0).toUpperCase()}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-gray-800 font-inter">
                          <span className="font-bold text-gray-950">{act.user?.name}</span>{" "}
                          {act.description}
                        </p>
                        <span className="text-[9px] text-gray-400 font-medium block mt-0.5 font-inter">
                          {new Date(act.createdAt).toLocaleString()}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* ──────────────────────────────────────────────────────── */}
      {/* MOBILE LAYOUT (lg:hidden) */}
      {/* ──────────────────────────────────────────────────────── */}
      <div className="lg:hidden space-y-6">
        {/* 1. Workspace Card */}
        <div className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
          <div className="flex items-center gap-3">
            <div
              className="w-10 h-10 rounded-lg flex items-center justify-center font-bold text-white text-lg shrink-0"
              style={{ backgroundColor: activeWorkspace?.color || "#4f46e5" }}
            >
              {activeWorkspace?.name?.charAt(0).toUpperCase() || "W"}
            </div>
            <div className="flex-1 min-w-0">
              <h2 className="font-extrabold text-base text-gray-900 truncate font-inter">
                {activeWorkspace?.name}
              </h2>
              <p className="text-xs text-gray-400 font-inter">Active Workspace</p>
            </div>
          </div>
          <hr className="border-gray-100 my-4" />
          <div className="grid grid-cols-4 gap-2 text-center">
            <div>
              <span className="block text-lg font-extrabold text-gray-900 font-inter">{stats?.team_count ?? 0}</span>
              <span className="text-[10px] text-gray-400 font-semibold font-inter uppercase">Teams</span>
            </div>
            <div>
              <span className="block text-lg font-extrabold text-gray-900 font-inter">{stats?.project_count ?? 0}</span>
              <span className="text-[10px] text-gray-400 font-semibold font-inter uppercase">Projects</span>
            </div>
            <div>
              <span className="block text-lg font-extrabold text-gray-900 font-inter">{stats?.task_count ?? 0}</span>
              <span className="text-[10px] text-gray-400 font-semibold font-inter uppercase">Tasks</span>
            </div>
            <div>
              <span className="block text-lg font-extrabold text-gray-900 font-inter">{stats?.member_count ?? 0}</span>
              <span className="text-[10px] text-gray-400 font-semibold font-inter uppercase">Members</span>
            </div>
          </div>
        </div>

        {/* 2. Active Sprint Card */}
        {stats?.currentSprint && stats?.sprintProgress && (
          <div className="bg-white border border-indigo-100 rounded-xl p-4 shadow-sm">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <svg className="w-5 h-5 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
                <h3 className="font-extrabold text-gray-900 text-sm font-inter">Active Sprint Health</h3>
              </div>
              <span className="text-[10px] bg-indigo-50 text-indigo-600 font-bold px-2 py-0.5 rounded-full font-inter">
                Velocity: {stats.sprintVelocity ?? 0} pts
              </span>
            </div>
            <div className="flex items-center justify-between text-xs text-gray-500 mb-1.5 font-semibold font-inter">
              <span>{stats.sprintProgress.completedTasks} / {stats.sprintProgress.totalTasks} Tasks Done</span>
              <span className="text-indigo-600 font-bold">{stats.sprintProgress.completionPercentage}%</span>
            </div>
            <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden">
              <div
                className="h-full bg-indigo-600 rounded-full"
                style={{ width: `${stats.sprintProgress.completionPercentage}%` }}
              />
            </div>
          </div>
        )}

        {/* 3. Stat Card Blocks (Tasks Today, In Progress, Review, Blocked) */}
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-white border-l-4 border-indigo-500 rounded-xl p-4 shadow-sm flex flex-col justify-between min-h-24">
            <div>
              <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.tasksDueToday ?? 0}</span>
              <span className="text-xs text-gray-500 font-bold font-inter">Tasks Today</span>
            </div>
            <span className="text-[9px] text-indigo-600 font-semibold font-inter">Real-time stats</span>
          </div>
          <div className="bg-white border-l-4 border-amber-500 rounded-xl p-4 shadow-sm flex flex-col justify-between min-h-24">
            <div>
              <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.inProgress ?? 0}</span>
              <span className="text-xs text-gray-500 font-bold font-inter">In Progress</span>
            </div>
            <span className="text-[9px] text-amber-600 font-semibold font-inter">Stable trend</span>
          </div>
          <div className="bg-white border-l-4 border-rose-500 rounded-xl p-4 shadow-sm flex flex-col justify-between min-h-24">
            <div>
              <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.inReview ?? 0}</span>
              <span className="text-xs text-gray-500 font-bold font-inter">Review</span>
            </div>
            <span className="text-[9px] text-rose-600 font-semibold font-inter">Stable trend</span>
          </div>
          <div className="bg-white border-l-4 border-gray-400 rounded-xl p-4 shadow-sm flex flex-col justify-between min-h-24">
            <div>
              <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.blocked ?? 0}</span>
              <span className="text-xs text-gray-500 font-bold font-inter">Blocked</span>
            </div>
            <span className="text-[9px] text-gray-400 font-semibold font-inter">Requires action</span>
          </div>
        </div>

        {/* 4. My Work Cards widget */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4">
          <div className="flex items-center justify-between mb-3 border-b border-gray-100 pb-2">
            <h3 className="font-bold text-gray-900 text-sm font-inter">My Work</h3>
            <span className="text-[10px] bg-slate-100 text-slate-600 font-bold px-2 py-0.5 rounded-full font-inter">
              {filteredTasks.length} {activeTab}
            </span>
          </div>
          <div className="flex border-b border-gray-150 mb-3 overflow-x-auto text-[9px] font-bold text-gray-500 uppercase tracking-wide shrink-0">
            {(["Assigned", "In Progress", "Upcoming", "Overdue", "Completed"] as const).map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`px-3 py-1.5 border-b-2 -mb-px transition-colors cursor-pointer shrink-0 font-inter ${
                  activeTab === tab
                    ? "border-indigo-600 text-indigo-600 font-bold"
                    : "border-transparent hover:text-gray-900"
                }`}
              >
                {tab} ({getCount(tab)})
              </button>
            ))}
          </div>
          <div className="divide-y divide-gray-100 max-h-64 overflow-y-auto">
            {filteredTasks.length === 0 ? (
              <div className="py-8 text-center text-xs text-gray-400 font-inter">No tasks in this category.</div>
            ) : (
              filteredTasks.map((task) => (
                <div
                  key={task.id}
                  onClick={() => navigate(`/projects/${task.projectId}`)}
                  className="py-3 hover:bg-gray-50 transition-colors flex items-center justify-between gap-3 cursor-pointer"
                >
                  <div className="min-w-0">
                    <p className="font-bold text-xs text-gray-800 font-inter truncate">{task.title}</p>
                    <span className="text-[9px] text-gray-400 font-semibold font-inter">
                      Project: {(task as any).project?.name || "Global"}
                    </span>
                  </div>
                  <span className={`text-[9px] font-bold px-2 py-0.5 rounded-full font-inter uppercase ${statusColors[task.status]}`}>
                    {task.status.replace("_", " ")}
                  </span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

    </div>
  );
}
