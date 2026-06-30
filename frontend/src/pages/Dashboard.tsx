import { useQuery } from "@tanstack/react-query";
import { Link, useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import type { Task } from "../types/Task";
import type { Project } from "../types/Project";
import type { Activity } from "../types/Activity";

export default function Dashboard() {
  const { activeWorkspaceId, activeWorkspace } = useWorkspace();
  const navigate = useNavigate();

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
  const { data: myTasks = [], isLoading: tasksLoading } = useQuery<Task[]>({
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
  const { data: projects = [], isLoading: projectsLoading } = useQuery<Project[]>({
    queryKey: ["projects", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      const res = await api.get("/projects", {
        params: { workspaceId: activeWorkspaceId },
      });
      return res.data?.data ?? [];
    },
    enabled: !!activeWorkspaceId,
  });

  // 4. Fetch activity feed
  const { data: activities = [], isLoading: activitiesLoading } = useQuery<Activity[]>({
    queryKey: ["workspace-activities", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      const res = await api.get(`/activities/workspaces/${activeWorkspaceId}`);
      return res.data?.data ?? [];
    },
    enabled: !!activeWorkspaceId,
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

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      
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
          <div className="bg-white rounded-xl shadow-xs border border-gray-200 p-6 flex flex-col max-h-[360px]">
            <div className="flex items-center justify-between mb-4 border-b border-gray-100 pb-3 shrink-0">
              <h3 className="font-bold text-gray-900 text-sm tracking-wide font-inter">My Work</h3>
              <span className="text-xs bg-slate-100 text-slate-600 font-bold px-2 py-0.5 rounded-full font-inter">
                {myTasks.length} Assigned
              </span>
            </div>
            <div className="flex-1 overflow-y-auto space-y-3 pr-1">
              {tasksLoading ? (
                <div className="py-4 text-center text-xs text-gray-500 font-inter">Loading tasks...</div>
              ) : myTasks.length === 0 ? (
                <div className="py-6 text-center text-xs text-gray-400 font-semibold font-inter">
                  No tasks assigned to you.
                </div>
              ) : (
                myTasks.map((t) => (
                  <div
                    key={t.id}
                    onClick={() => navigate(`/projects/${t.projectId}`)}
                    className="p-3 border border-gray-100 hover:border-indigo-200 rounded-lg transition-colors cursor-pointer bg-gray-50/50 space-y-2"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <p className="text-xs font-bold text-gray-900 line-clamp-1 font-inter">{t.title}</p>
                      <span className={`text-[9px] font-bold px-1.5 py-0.5 rounded-full uppercase border shrink-0 font-inter ${priorityColors[t.priority]}`}>
                        {t.priority}
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-[10px] text-gray-500 font-inter pt-1">
                      <span className={`px-2 py-0.5 rounded-full text-[9px] font-bold ${statusColors[t.status]}`}>
                        {t.status}
                      </span>
                      <span>Points: {t.storyPoints || 0} SP</span>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Activity Log Feed */}
          <div className="bg-white rounded-xl shadow-xs border border-gray-200 p-6 flex flex-col max-h-[360px]">
            <div className="flex items-center justify-between mb-4 border-b border-gray-100 pb-3 shrink-0">
              <h3 className="font-bold text-gray-900 text-sm tracking-wide font-inter">Recent Activity</h3>
            </div>
            <div className="flex-1 overflow-y-auto space-y-4 pr-1">
              {activitiesLoading ? (
                <div className="py-4 text-center text-xs text-gray-500 font-inter">Loading activities...</div>
              ) : activities.length === 0 ? (
                <div className="py-6 text-center text-xs text-gray-400 font-semibold font-inter">
                  No recent activities in this workspace.
                </div>
              ) : (
                <div className="relative border-l-2 border-gray-100 pl-4 ml-2 space-y-4">
                  {activities.slice(0, 10).map((act) => (
                    <div key={act.id} className="relative text-xs">
                      {/* Timeline marker */}
                      <span className="absolute -left-[23px] top-0.5 w-2.5 h-2.5 bg-indigo-600 rounded-full border-2 border-white ring-4 ring-indigo-50" />
                      <div>
                        <p className="font-semibold text-gray-800 font-inter">
                          <span className="font-bold text-gray-900">{act.user?.name || "User"}</span> {act.description}
                        </p>
                        <span className="text-[10px] text-gray-400 font-inter block mt-1">
                          {new Date(act.createdAt).toLocaleDateString()} at {new Date(act.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
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

    </div>
  );
}
