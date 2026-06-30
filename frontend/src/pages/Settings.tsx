import { useState, useEffect } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { useWorkspace } from "../context/WorkspaceContext";
import { useToast } from "../context/useToast";
import { getOfflineQueue } from "../api/offlineManager";
import type { Task } from "../types/Task";
import type { Activity } from "../types/Activity";

type ActiveTab = "profile" | "search" | "calendar" | "timeline" | "diagnostics";

export default function Settings() {
  const { user, refreshUserSession } = useAuth();
  const { activeWorkspaceId } = useWorkspace();
  const { showToast } = useToast();
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const [activeTab, setActiveTab] = useState<ActiveTab>("profile");

  // Profile Form state
  const [profileName, setProfileName] = useState(user?.name || "");
  const [profileBio, setProfileBio] = useState("");
  const [profilePassword, setProfilePassword] = useState("");
  const [profileLoading, setProfileLoading] = useState(false);

  // Search State
  const [searchQuery, setSearchQuery] = useState("");
  const [searchPriority, setSearchPriority] = useState("");
  const [searchStatus, setSearchStatus] = useState("");
  const [searchType, setSearchType] = useState("all");

  // Calendar State
  const [currentDate, setCurrentDate] = useState(new Date());

  // Diagnostics State
  const [pingLatency, setPingLatency] = useState<string | null>(null);
  const [pingLoading, setPingLoading] = useState(false);
  const [startTime] = useState(performance.now());
  const [pageLatency, setPageLatency] = useState<string | null>(null);

  useEffect(() => {
    if (user) {
      setProfileName(user.name);
    }
  }, [user]);

  useEffect(() => {
    // Measure visual latency
    const duration = performance.now() - startTime;
    setPageLatency(`${Math.round(duration)}ms`);
  }, [startTime]);

  // Query Workspace Search Results
  const { data: searchResults, isLoading: searchLoading } = useQuery({
    queryKey: ["workspace-search", searchQuery, searchPriority, searchStatus, searchType, activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return null;
      const res = await api.get("/search", {
        params: {
          q: searchQuery,
          type: searchType,
          limit: 20,
          priority: searchPriority || undefined,
          status: searchStatus || undefined,
        },
      });
      return res.data?.data;
    },
    enabled: activeTab === "search" && !!activeWorkspaceId,
  });

  // Query Workspace Activities (Timeline)
  const { data: timelineActivities = [], isLoading: timelineLoading } = useQuery<Activity[]>({
    queryKey: ["timeline-activities", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      const res = await api.get(`/activities/workspaces/${activeWorkspaceId}`);
      return res.data?.data ?? [];
    },
    enabled: activeTab === "timeline" && !!activeWorkspaceId,
  });

  // Query Workspace Tasks for Calendar
  const { data: calendarTasks = [] } = useQuery<Task[]>({
    queryKey: ["calendar-tasks", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      const res = await api.get("/search", {
        params: { q: "", type: "tasks", limit: 100 },
      });
      return res.data?.data?.tasks ?? [];
    },
    enabled: activeTab === "calendar" && !!activeWorkspaceId,
  });

  // Update Profile Mutation
  const updateProfileMutation = useMutation({
    mutationFn: async () => {
      setProfileLoading(true);
      const data: any = { name: profileName, bio: profileBio };
      if (profilePassword.trim()) {
        data.password = profilePassword;
      }
      await api.patch("/auth/profile", data);
    },
    onSuccess: async () => {
      showToast("Profile updated successfully", "success");
      setProfilePassword("");
      await refreshUserSession?.();
      queryClient.invalidateQueries();
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to update profile", "error");
    },
    onSettled: () => {
      setProfileLoading(false);
    }
  });

  // Ping Backend
  const handlePing = async () => {
    setPingLoading(true);
    const start = performance.now();
    try {
      await api.get("/health");
      const latency = performance.now() - start;
      setPingLatency(`${Math.round(latency)}ms`);
    } catch {
      setPingLatency("Failed (offline/error)");
    } finally {
      setPingLoading(false);
    }
  };

  // Helper: Month Calendar Generator
  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1).getDay();
    const totalDays = new Date(year, month + 1, 0).getDate();

    const days = [];
    for (let i = 0; i < firstDay; i++) {
      days.push(null);
    }
    for (let d = 1; d <= totalDays; d++) {
      days.push(new Date(year, month, d));
    }
    return days;
  };

  const handlePrevMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const handleNextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const calendarDays = getDaysInMonth(currentDate);
  const weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

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
    <div className="bg-white rounded-xl shadow-xs border border-gray-200 min-h-[70vh] flex flex-col md:flex-row overflow-hidden animate-in fade-in duration-200">
      
      {/* Side Nav tabs */}
      <div className="w-full md:w-64 border-b md:border-b-0 md:border-r border-gray-200 bg-gray-50/50 p-4 space-y-1">
        <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider px-3 mb-3 font-inter">Workspace Hub</h3>
        {[
          { id: "profile", label: "My Profile" },
          { id: "search", label: "Global Search" },
          { id: "calendar", label: "Task Calendar" },
          { id: "timeline", label: "Activity Logs" },
          { id: "diagnostics", label: "Diagnostics" }
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as ActiveTab)}
            className={`w-full text-left px-4 py-2.5 rounded-lg text-sm font-semibold transition-all font-inter cursor-pointer ${
              activeTab === tab.id
                ? "bg-white text-indigo-600 shadow-xs border border-gray-200/80 font-bold"
                : "text-gray-600 hover:bg-gray-100/70"
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Panel Content */}
      <div className="flex-1 p-8 overflow-y-auto">
        
        {/* PROFILE TAB */}
        {activeTab === "profile" && (
          <div className="max-w-md space-y-6">
            <div>
              <h2 className="text-xl font-bold text-gray-900 font-inter">Profile Settings</h2>
              <p className="text-xs text-gray-500 font-inter mt-1">Manage your developer profile and secure credentials.</p>
            </div>
            <form
              onSubmit={(e) => {
                e.preventDefault();
                updateProfileMutation.mutate();
              }}
              className="space-y-4"
            >
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Full Name</label>
                <input
                  type="text"
                  required
                  value={profileName}
                  onChange={(e) => setProfileName(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">Developer Bio</label>
                <textarea
                  placeholder="Tell us about yourself..."
                  value={profileBio}
                  onChange={(e) => setProfileBio(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 h-24"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1 font-inter">New Password (optional)</label>
                <input
                  type="password"
                  placeholder="••••••••"
                  value={profilePassword}
                  onChange={(e) => setProfilePassword(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500"
                />
              </div>
              <button
                type="submit"
                disabled={profileLoading}
                className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-400 text-white text-sm font-semibold rounded-lg font-inter transition-colors cursor-pointer"
              >
                {profileLoading ? "Saving..." : "Update Profile"}
              </button>
            </form>
          </div>
        )}

        {/* SEARCH TAB */}
        {activeTab === "search" && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-bold text-gray-900 font-inter">Global Workspace Search</h2>
              <p className="text-xs text-gray-500 font-inter mt-1">Unified query engine indexing tasks, projects, comments, and sprints.</p>
            </div>
            
            {/* Search Filters */}
            <div className="flex flex-col md:flex-row items-center gap-3 bg-gray-50 p-4 border border-gray-200 rounded-xl">
              <input
                type="text"
                placeholder="Search anything..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="flex-1 px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white"
              />
              <select
                value={searchType}
                onChange={(e) => setSearchType(e.target.value)}
                className="w-full md:w-36 px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white"
              >
                <option value="all">All Content</option>
                <option value="tasks">Tasks Only</option>
                <option value="projects">Projects Only</option>
                <option value="comments">Comments</option>
                <option value="sprints">Sprints</option>
              </select>
              <select
                value={searchPriority}
                onChange={(e) => setSearchPriority(e.target.value)}
                className="w-full md:w-32 px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white"
              >
                <option value="">Any Priority</option>
                <option value="LOW">Low</option>
                <option value="MEDIUM">Medium</option>
                <option value="HIGH">High</option>
                <option value="URGENT">Urgent</option>
              </select>
              <select
                value={searchStatus}
                onChange={(e) => setSearchStatus(e.target.value)}
                className="w-full md:w-32 px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white"
              >
                <option value="">Any Status</option>
                <option value="TODO">Todo</option>
                <option value="IN_PROGRESS">In Progress</option>
                <option value="REVIEW">Review</option>
                <option value="BLOCKED">Blocked</option>
                <option value="DONE">Done</option>
              </select>
            </div>

            {/* Results Grid */}
            <div className="space-y-4">
              {searchLoading ? (
                <div className="py-8 text-center text-xs text-gray-500 font-inter">Executing query...</div>
              ) : !searchResults ? (
                <div className="py-8 text-center text-xs text-gray-400 font-inter">Enter queries to begin.</div>
              ) : (
                <div className="space-y-6">
                  {/* Task Results */}
                  {searchResults.tasks?.length > 0 && (
                    <div className="space-y-2">
                      <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider font-inter">Tasks ({searchResults.tasks.length})</h4>
                      <div className="divide-y divide-gray-100 border border-gray-200 rounded-xl overflow-hidden bg-white">
                        {searchResults.tasks.map((task: any) => (
                          <div
                            key={task.id}
                            onClick={() => navigate(`/projects/${task.project?.id || ""}`)}
                            className="p-4 hover:bg-gray-50 transition-colors flex items-center justify-between gap-4 cursor-pointer"
                          >
                            <div>
                              <div className="flex items-center gap-2">
                                <span className={`w-2 h-2 rounded-full ${statusColors[task.status]}`} />
                                <span className="font-bold text-xs text-gray-900 font-inter">{task.title}</span>
                              </div>
                              <span className="text-[10px] text-gray-400 font-inter mt-1 block">Project: {task.project?.name || "N/A"}</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <span className={`text-[9px] font-bold px-1.5 py-0.5 rounded-full uppercase border ${priorityColors[task.priority]}`}>
                                {task.priority}
                              </span>
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Project Results */}
                  {searchResults.projects?.length > 0 && (
                    <div className="space-y-2">
                      <h4 className="text-xs font-bold text-gray-400 uppercase tracking-wider font-inter">Projects ({searchResults.projects.length})</h4>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        {searchResults.projects.map((proj: any) => (
                          <div
                            key={proj.id}
                            onClick={() => navigate(`/projects/${proj.id}`)}
                            className="p-4 border border-gray-200 hover:border-indigo-500 rounded-xl bg-white transition-all cursor-pointer"
                          >
                            <h5 className="font-bold text-xs text-gray-900 font-inter">{proj.name}</h5>
                            <p className="text-[10px] text-gray-500 line-clamp-1 mt-1 font-inter">{proj.description}</p>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Empty View */}
                  {(!searchResults.tasks?.length && !searchResults.projects?.length) && (
                    <div className="py-8 text-center text-xs text-gray-400 font-bold font-inter">No results matching your filters.</div>
                  )}
                </div>
              )}
            </div>
          </div>
        )}

        {/* CALENDAR TAB */}
        {activeTab === "calendar" && (
          <div className="space-y-6">
            <div className="flex items-center justify-between border-b border-gray-100 pb-3">
              <div>
                <h2 className="text-xl font-bold text-gray-900 font-inter">Task Calendar</h2>
                <p className="text-xs text-gray-500 font-inter mt-1">Monthly task scheduling visualizer scoped to the active workspace.</p>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={handlePrevMonth}
                  className="p-1 hover:bg-gray-100 border border-gray-200 rounded-lg cursor-pointer text-gray-600"
                >
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                  </svg>
                </button>
                <span className="text-sm font-bold text-gray-800 font-inter min-w-36 text-center">
                  {currentDate.toLocaleDateString(undefined, { month: "long", year: "numeric" })}
                </span>
                <button
                  onClick={handleNextMonth}
                  className="p-1 hover:bg-gray-100 border border-gray-200 rounded-lg cursor-pointer text-gray-600"
                >
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                  </svg>
                </button>
              </div>
            </div>

            {/* Week Days Headers */}
            <div className="grid grid-cols-7 gap-2 text-center text-xs font-bold text-gray-400 uppercase tracking-wider font-inter">
              {weekDays.map((d) => (
                <div key={d} className="py-1">{d}</div>
              ))}
            </div>

            {/* Days Grid */}
            <div className="grid grid-cols-7 gap-2 border border-gray-100 rounded-xl bg-gray-50 p-2 min-h-[300px]">
              {calendarDays.map((day, idx) => {
                if (!day) return <div key={`empty-${idx}`} className="bg-transparent" />;

                // Find tasks due on this day
                const dayTasks = calendarTasks.filter((t) => {
                  if (!t.dueDate) return false;
                  const due = new Date(t.dueDate);
                  return (
                    due.getDate() === day.getDate() &&
                    due.getMonth() === day.getMonth() &&
                    due.getFullYear() === day.getFullYear()
                  );
                });

                return (
                  <div
                    key={day.toISOString()}
                    className="bg-white border border-gray-200/80 rounded-lg p-2 min-h-20 flex flex-col justify-between hover:shadow-xs transition-shadow relative overflow-hidden"
                  >
                    <span className="text-xs font-bold text-gray-400 font-inter">{day.getDate()}</span>
                    <div className="flex-1 overflow-y-auto space-y-1 mt-1.5">
                      {dayTasks.map((t) => (
                        <div
                          key={t.id}
                          onClick={() => navigate(`/projects/${t.projectId}`)}
                          title={t.title}
                          className="text-[9px] font-bold text-white px-1.5 py-0.5 rounded-sm truncate cursor-pointer leading-tight"
                          style={{
                            backgroundColor:
                              t.priority === "URGENT"
                                ? "#ef4444"
                                : t.priority === "HIGH"
                                  ? "#f97316"
                                  : t.priority === "MEDIUM"
                                    ? "#3b82f6"
                                    : "#94a3b8",
                          }}
                        >
                          {t.title}
                        </div>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* TIMELINE TAB */}
        {activeTab === "timeline" && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-bold text-gray-900 font-inter">Workspace Timeline</h2>
              <p className="text-xs text-gray-500 font-inter mt-1">Audit log of all developer changes inside the workspace.</p>
            </div>
            {timelineLoading ? (
              <div className="py-8 text-center text-xs text-gray-500 font-inter">Loading audit log...</div>
            ) : timelineActivities.length === 0 ? (
              <div className="py-8 text-center text-xs text-gray-400 font-bold font-inter">No recent audit activity.</div>
            ) : (
              <div className="relative border-l-2 border-gray-100 pl-6 ml-3 space-y-6 py-2">
                {timelineActivities.map((act) => (
                  <div key={act.id} className="relative text-xs">
                    <span className="absolute -left-[31px] top-0.5 w-3 h-3 bg-indigo-600 rounded-full border-2 border-white ring-4 ring-indigo-50" />
                    <div>
                      <p className="font-semibold text-gray-800 font-inter">
                        <span className="font-bold text-gray-900">{act.user?.name || "System"}</span> {act.description}
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
        )}

        {/* DIAGNOSTICS TAB */}
        {activeTab === "diagnostics" && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-bold text-gray-900 font-inter">System Diagnostics</h2>
              <p className="text-xs text-gray-500 font-inter mt-1">Network performance and client sync statistics.</p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              
              <div className="p-4 border border-gray-200 rounded-xl space-y-4 bg-gray-50/50">
                <h4 className="font-bold text-xs text-gray-900 uppercase tracking-wider font-inter">Network Liveness</h4>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-gray-600 font-semibold font-inter">API Ping Latency</span>
                  <span className="text-xs font-bold font-mono text-gray-800">{pingLatency || "Not pinged"}</span>
                </div>
                <button
                  onClick={handlePing}
                  disabled={pingLoading}
                  className="w-full py-2 bg-white border border-gray-300 hover:bg-gray-100 text-xs font-semibold rounded-lg font-inter transition-all cursor-pointer"
                >
                  {pingLoading ? "Pinging..." : "Test Latency"}
                </button>
              </div>

              <div className="p-4 border border-gray-200 rounded-xl space-y-3 bg-gray-50/50">
                <h4 className="font-bold text-xs text-gray-900 uppercase tracking-wider font-inter">Sync Statistics</h4>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-gray-600 font-semibold font-inter">Mutations Queued</span>
                  <span className="text-xs font-bold font-mono text-amber-600">{getOfflineQueue().length} pending</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-xs text-gray-600 font-semibold font-inter">Visual Load Timing</span>
                  <span className="text-xs font-bold font-mono text-indigo-600">{pageLatency || "Measuring..."}</span>
                </div>
              </div>

            </div>
          </div>
        )}

      </div>

    </div>
  );
}
