import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useAuth } from "../auth/AuthContext";
import type { Task } from "../types/Task";

export default function Dashboard() {
  const { activeWorkspaceId, activeWorkspace } = useWorkspace();
  const { user, logout } = useAuth();
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
      const allTasks: Task[] = res.data?.data ?? [];
      return allTasks.filter(
        (t: any) => t.project?.team?.workspaceId === activeWorkspaceId
      );
    },
    enabled: !!activeWorkspaceId,
  });

  const handleLogout = async () => {
    await logout();
    navigate("/login", { replace: true });
  };

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
    <div className="space-y-6 max-w-4xl mx-auto animate-in fade-in duration-300">
      
      {/* 1. Greeting Row */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-xl font-bold text-gray-900 font-inter leading-tight">
            Good morning, <br />{user?.name || "User"} 👋
          </h1>
          <p className="text-xs text-gray-500 font-inter mt-1">Here's what's happening with your work.</p>
        </div>
        <button
          onClick={handleLogout}
          className="px-3.5 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white text-xs font-bold rounded-lg font-inter flex items-center gap-1.5 cursor-pointer shadow-xs transition-colors shrink-0"
        >
          <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
          </svg>
          Logout
        </button>
      </div>

      {/* 2. Workspace Card */}
      <div className="bg-white border border-gray-250 rounded-xl p-5 shadow-xs">
        <div className="flex items-center gap-3">
          <div
            className="w-8 h-8 rounded-lg flex items-center justify-center font-bold text-white text-base shrink-0"
            style={{ backgroundColor: activeWorkspace?.color || "#4f46e5" }}
          >
            {activeWorkspace?.name?.charAt(0).toUpperCase() || "W"}
          </div>
          <div className="flex-1 min-w-0">
            <h2 className="font-extrabold text-sm text-gray-900 truncate font-inter">
              {activeWorkspace?.name}
            </h2>
            <p className="text-xs text-gray-400 font-inter mt-0.5">Active Workspace</p>
          </div>
        </div>
        <hr className="border-gray-250/80 my-4" />
        <div className="grid grid-cols-4 gap-2 text-center">
          <div>
            <span className="block text-base font-extrabold text-gray-900 font-inter">{stats?.team_count ?? 0}</span>
            <span className="text-[9px] text-gray-400 font-semibold font-inter uppercase tracking-wide">Teams</span>
          </div>
          <div>
            <span className="block text-base font-extrabold text-gray-900 font-inter">{stats?.project_count ?? 0}</span>
            <span className="text-[9px] text-gray-400 font-semibold font-inter uppercase tracking-wide">Projects</span>
          </div>
          <div>
            <span className="block text-base font-extrabold text-gray-900 font-inter">{stats?.task_count ?? 0}</span>
            <span className="text-[9px] text-gray-400 font-semibold font-inter uppercase tracking-wide">Tasks</span>
          </div>
          <div>
            <span className="block text-base font-extrabold text-gray-900 font-inter">{stats?.member_count ?? 0}</span>
            <span className="text-[9px] text-gray-400 font-semibold font-inter uppercase tracking-wide">Members</span>
          </div>
        </div>
      </div>

      {/* 3. Active Sprint Card */}
      {statsLoading ? (
        <div className="py-4 text-center text-xs text-gray-500 font-inter">Loading sprint details...</div>
      ) : stats?.currentSprint && stats?.sprintProgress ? (
        <div className="bg-white border border-indigo-100 rounded-xl p-4 shadow-xs">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <svg className="w-5 h-5 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
              <h3 className="font-extrabold text-gray-900 text-xs font-inter uppercase tracking-wider">{stats.currentSprint.name}</h3>
            </div>
            <span className="text-[9px] bg-indigo-50 text-indigo-600 font-bold px-2 py-0.5 rounded-full font-inter">
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
      ) : null}

      {/* 4. Stat Card Blocks (Tasks Today, In Progress, Review, Blocked) */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-white border-l-4 border-indigo-500 rounded-xl p-4 shadow-xs flex flex-col justify-between min-h-24">
          <div>
            <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.tasksDueToday ?? 0}</span>
            <span className="text-xs text-gray-500 font-bold font-inter">Tasks Today</span>
          </div>
          <span className="text-[9px] text-indigo-600 font-semibold font-inter">Real-time stats</span>
        </div>
        <div className="bg-white border-l-4 border-amber-500 rounded-xl p-4 shadow-xs flex flex-col justify-between min-h-24">
          <div>
            <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.inProgress ?? 0}</span>
            <span className="text-xs text-gray-500 font-bold font-inter">In Progress</span>
          </div>
          <span className="text-[9px] text-amber-600 font-semibold font-inter">Stable trend</span>
        </div>
        <div className="bg-white border-l-4 border-rose-500 rounded-xl p-4 shadow-xs flex flex-col justify-between min-h-24">
          <div>
            <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.inReview ?? 0}</span>
            <span className="text-xs text-gray-500 font-bold font-inter">Review</span>
          </div>
          <span className="text-[9px] text-rose-600 font-semibold font-inter">Stable trend</span>
        </div>
        <div className="bg-white border-l-4 border-gray-400 rounded-xl p-4 shadow-xs flex flex-col justify-between min-h-24">
          <div>
            <span className="block text-2xl font-black text-gray-900 font-inter">{stats?.blocked ?? 0}</span>
            <span className="text-xs text-gray-500 font-bold font-inter">Blocked</span>
          </div>
          <span className="text-[9px] text-gray-400 font-semibold font-inter">Requires action</span>
        </div>
      </div>

      {/* 5. My Work Cards widget */}
      <div className="bg-white rounded-xl shadow-xs border border-gray-250 p-5">
        <div className="flex items-center justify-between mb-3 border-b border-gray-100 pb-2">
          <h3 className="font-bold text-gray-900 text-sm font-inter">My Work</h3>
          <span className="text-[10px] bg-slate-100 text-slate-600 font-bold px-2 py-0.5 rounded-full font-inter">
            {filteredTasks.length} {activeTab}
          </span>
        </div>
        
        {/* Tab selection */}
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
        
        {/* Tasks items list */}
        <div className="divide-y divide-gray-100 max-h-80 overflow-y-auto pr-1">
          {filteredTasks.length === 0 ? (
            <div className="py-12 text-center text-xs text-gray-400 font-inter font-semibold">
              You have no tasks in this category. 🎉
            </div>
          ) : (
            filteredTasks.map((task) => (
              <div
                key={task.id}
                onClick={() => navigate(`/projects/${task.projectId}`)}
                className="py-3.5 hover:bg-gray-50 transition-colors flex items-center justify-between gap-3 cursor-pointer"
              >
                <div className="min-w-0">
                  <p className="font-bold text-xs text-gray-800 font-inter truncate">{task.title}</p>
                  <span className="text-[9px] text-gray-400 font-semibold font-inter block mt-0.5">
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
  );
}
