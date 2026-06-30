import { useState, useEffect, useRef } from "react";
import { Link, useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { useWorkspace } from "../context/WorkspaceContext";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { getSyncStatus, getOfflineQueue, clearOfflineQueue, syncOfflineMutations } from "../api/offlineManager";
import CreateWorkspaceModal from "./CreateWorkspaceModal";
import EditWorkspaceModal from "./EditWorkspaceModal";
import WorkspaceMembersModal from "./WorkspaceMembersModal";
import type { Notification } from "../types/Notification";

interface LayoutProps {
  children: React.ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const { user, logout } = useAuth();
  const { activeWorkspaceId, activeWorkspace, workspaces, switchWorkspace } = useWorkspace();
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const location = useLocation();

  const [wsDropdownOpen, setWsDropdownOpen] = useState(false);
  const [notifDropdownOpen, setNotifDropdownOpen] = useState(false);
  const [syncQueueOpen, setSyncQueueOpen] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  
  // Modals state
  const [createWsOpen, setCreateWsOpen] = useState(false);
  const [editWsOpen, setEditWsOpen] = useState(false);
  const [membersWsOpen, setMembersWsOpen] = useState(false);

  // Sync state
  const [syncStatus, setSyncStatus] = useState(getSyncStatus());
  const [queuedMutations, setQueuedMutations] = useState(getOfflineQueue());

  const wsRef = useRef<HTMLDivElement>(null);
  const notifRef = useRef<HTMLDivElement>(null);
  const syncRef = useRef<HTMLDivElement>(null);

  // Listen to offline status changes
  useEffect(() => {
    const handleSyncStatus = () => {
      setSyncStatus(getSyncStatus());
      setQueuedMutations(getOfflineQueue());
    };
    window.addEventListener("sync-status-changed", handleSyncStatus);
    window.addEventListener("sync-queue-updated", handleSyncStatus);
    return () => {
      window.removeEventListener("sync-status-changed", handleSyncStatus);
      window.removeEventListener("sync-queue-updated", handleSyncStatus);
    };
  }, []);

  // Close dropdowns on outside click
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (wsRef.current && !wsRef.current.contains(e.target as Node)) {
        setWsDropdownOpen(false);
      }
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
        setNotifDropdownOpen(false);
      }
      if (syncRef.current && !syncRef.current.contains(e.target as Node)) {
        setSyncQueueOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Fetch unread notifications count
  const { data: unreadCount = 0 } = useQuery<number>({
    queryKey: ["unread-notifications-count", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return 0;
      const res = await api.get("/notifications/unread-count");
      return res.data?.data?.count ?? 0;
    },
    refetchInterval: 30000, // poll every 30s
    enabled: !!user && !!activeWorkspaceId,
  });

  // Fetch notifications
  const { data: notifications = [] } = useQuery<Notification[]>({
    queryKey: ["notifications", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      const res = await api.get("/notifications");
      // Res contains grouped categories today/yesterday/older, flatten them for display
      const groups = res.data?.data;
      if (groups) {
        return [...(groups.today || []), ...(groups.yesterday || []), ...(groups.older || [])];
      }
      return [];
    },
    enabled: notifDropdownOpen && !!activeWorkspaceId,
  });

  // Mark all as read mutation
  const markAllReadMutation = useMutation({
    mutationFn: async () => {
      await api.patch("/notifications/read-all");
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["unread-notifications-count", activeWorkspaceId] });
      queryClient.invalidateQueries({ queryKey: ["notifications", activeWorkspaceId] });
    },
  });

  const handleLogout = async () => {
    await logout();
    navigate("/login", { replace: true });
  };

  const navLinks = [
    { name: "Dashboard", path: "/", icon: (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
      </svg>
    )},
    { name: "Teams", path: "/teams", icon: (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
    )},
    { name: "Projects", path: "/projects", icon: (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2zm5-3a2 2 0 00-2 2v1h8V4a2 2 0 00-2-2H8z" />
      </svg>
    )},
    { name: "Settings & Hub", path: "/settings", icon: (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
    )}
  ];

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* LEFT SIDEBAR */}
      <aside className="hidden md:flex w-64 bg-slate-900 border-r border-slate-800 flex-col z-20 shrink-0">
        <div className="h-16 px-6 flex items-center border-b border-slate-800">
          <Link to="/" className="text-xl font-bold text-white tracking-wide font-inter">
            TeamFlow <span className="text-xs bg-indigo-600 text-indigo-100 font-semibold px-2 py-0.5 rounded-full font-inter">RC1</span>
          </Link>
        </div>
        <nav className="flex-1 px-4 py-6 space-y-1">
          {navLinks.map((link) => {
            const isSel = location.pathname === link.path;
            return (
              <Link
                key={link.name}
                to={link.path}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-semibold transition-all font-inter ${
                  isSel
                    ? "bg-indigo-600 text-white shadow-md shadow-indigo-600/10"
                    : "text-slate-400 hover:bg-slate-800 hover:text-white"
                }`}
              >
                {link.icon}
                {link.name}
              </Link>
            );
          })}
        </nav>
      </aside>

      {/* CONTENT SHELL AREA */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* TOP BAR HEADER */}
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-4 md:px-8 z-10">
          <div className="flex items-center gap-2">
            <button
              onClick={() => setMobileMenuOpen(true)}
              className="md:hidden block text-slate-500 hover:text-slate-800 p-1.5 rounded-lg hover:bg-slate-100 cursor-pointer"
            >
              <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          
          {/* Workspace Switcher */}
          <div ref={wsRef} className="relative">
            <button
              onClick={() => setWsDropdownOpen(!wsDropdownOpen)}
              className="flex items-center gap-2 px-3 py-1.5 hover:bg-gray-50 border border-gray-200 rounded-lg text-sm font-semibold text-gray-900 font-inter cursor-pointer"
            >
              <span
                className="w-3.5 h-3.5 rounded-full border border-black/10"
                style={{ backgroundColor: activeWorkspace?.color || "#4f46e5" }}
              />
              {activeWorkspace?.name || "Select Workspace"}
              <svg className={`w-4 h-4 text-gray-500 transition-transform ${wsDropdownOpen ? "rotate-180" : ""}`} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
              </svg>
            </button>

            {wsDropdownOpen && (
              <div className="absolute left-0 mt-2 w-64 bg-white border border-gray-200 rounded-xl shadow-lg py-2 animate-in fade-in slide-in-from-top-2 duration-100 z-50">
                <div className="px-4 py-1.5 text-xs font-semibold text-gray-400 uppercase tracking-wider font-inter">
                  Workspaces
                </div>
                {workspaces.map((w) => (
                  <button
                    key={w.id}
                    onClick={async () => {
                      await switchWorkspace(w.id);
                      setWsDropdownOpen(false);
                    }}
                    className={`w-full text-left px-4 py-2.5 hover:bg-gray-50 text-sm font-semibold flex items-center justify-between font-inter cursor-pointer ${
                      w.id === activeWorkspaceId ? "text-indigo-600 font-bold" : "text-gray-700"
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <span className="w-3 h-3 rounded-full" style={{ backgroundColor: w.color }} />
                      {w.name}
                    </div>
                    {w.id === activeWorkspaceId && (
                      <svg className="w-4 h-4 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    )}
                  </button>
                ))}
                <div className="border-t border-gray-100 my-2" />
                <button
                  onClick={() => {
                    setWsDropdownOpen(false);
                    setCreateWsOpen(true);
                  }}
                  className="w-full text-left px-4 py-2 hover:bg-indigo-50 text-xs font-bold text-indigo-600 flex items-center gap-2 font-inter cursor-pointer"
                >
                  <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                  </svg>
                  New Workspace
                </button>
                {activeWorkspaceId && (
                  <>
                    <button
                      onClick={() => {
                        setWsDropdownOpen(false);
                        setEditWsOpen(true);
                      }}
                      className="w-full text-left px-4 py-2 hover:bg-gray-50 text-xs font-semibold text-gray-600 flex items-center gap-2 font-inter cursor-pointer"
                    >
                      <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 ... 15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                      Workspace Settings
                    </button>
                    <button
                      onClick={() => {
                        setWsDropdownOpen(false);
                        setMembersWsOpen(true);
                      }}
                      className="w-full text-left px-4 py-2 hover:bg-gray-50 text-xs font-semibold text-gray-600 flex items-center gap-2 font-inter cursor-pointer"
                    >
                      <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                      </svg>
                      Manage Members
                    </button>
                  </>
                )}
              </div>
            )}
          </div>
        </div>

          {/* Right Header Panel */}
          <div className="flex items-center gap-4">
            
            {/* Sync Status Badge */}
            <div ref={syncRef} className="relative">
              <button
                onClick={() => setSyncQueueOpen(!syncQueueOpen)}
                className={`p-1.5 rounded-lg border transition-all cursor-pointer ${
                  syncStatus === "synced"
                    ? "bg-emerald-50 border-emerald-200 text-emerald-600"
                    : syncStatus === "pending"
                      ? "bg-amber-50 border-amber-200 text-amber-600"
                      : syncStatus === "syncing"
                        ? "bg-blue-50 border-blue-200 text-blue-600"
                        : "bg-rose-50 border-rose-200 text-rose-600"
                }`}
              >
                {syncStatus === "syncing" ? (
                  <svg className="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                ) : (
                  <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z" />
                  </svg>
                )}
              </button>

              {syncQueueOpen && (
                <div className="absolute right-0 mt-2 w-80 bg-white border border-gray-200 rounded-xl shadow-lg p-4 animate-in fade-in slide-in-from-top-2 duration-100 z-50">
                  <h4 className="font-bold text-gray-900 text-sm font-inter mb-1">Sync Engine Status</h4>
                  <p className="text-xs text-gray-500 font-inter mb-3">
                    {syncStatus === "offline"
                      ? "Offline mode. Operation writes are queued."
                      : syncStatus === "pending"
                        ? `${queuedMutations.length} mutations waiting to be synchronized.`
                        : "All changes are synced successfully."}
                  </p>
                  
                  {queuedMutations.length > 0 && (
                    <div className="max-h-32 overflow-y-auto divide-y divide-gray-100 border border-gray-100 rounded-lg p-2 mb-3 bg-gray-50">
                      {queuedMutations.map((mut) => (
                        <div key={mut.id} className="py-1 text-[11px] font-semibold font-mono text-gray-600 flex items-center justify-between">
                          <span>{mut.method} {mut.url}</span>
                          <span className="text-amber-500 font-inter text-[10px]">Pending</span>
                        </div>
                      ))}
                    </div>
                  )}

                  <div className="flex items-center justify-between gap-2 border-t border-gray-100 pt-3">
                    <button
                      onClick={() => {
                        clearOfflineQueue();
                        setQueuedMutations([]);
                        setSyncStatus("synced");
                      }}
                      className="px-2 py-1 text-xs text-red-600 font-bold hover:bg-red-50 rounded-md cursor-pointer"
                    >
                      Clear Queue
                    </button>
                    {syncStatus === "pending" && (
                      <button
                        onClick={async () => {
                          await syncOfflineMutations();
                        }}
                        className="px-3 py-1 text-xs text-white bg-indigo-600 font-bold hover:bg-indigo-700 rounded-md cursor-pointer"
                      >
                        Sync Now
                      </button>
                    )}
                  </div>
                </div>
              )}
            </div>

            {/* Notifications Bell */}
            <div ref={notifRef} className="relative">
              <button
                onClick={() => setNotifDropdownOpen(!notifDropdownOpen)}
                className="p-1.5 hover:bg-gray-100 border border-gray-200 rounded-lg text-gray-600 transition-all relative cursor-pointer"
              >
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
                {unreadCount > 0 && (
                  <span className="absolute -top-1 -right-1 bg-red-500 text-white font-bold text-[10px] w-4.5 h-4.5 rounded-full flex items-center justify-center border-2 border-white font-inter">
                    {unreadCount}
                  </span>
                )}
              </button>

              {notifDropdownOpen && (
                <div className="absolute right-0 mt-2 w-80 bg-white border border-gray-200 rounded-xl shadow-lg py-2 animate-in fade-in slide-in-from-top-2 duration-100 z-50 flex flex-col max-h-96">
                  <div className="px-4 py-2 border-b border-gray-100 flex items-center justify-between">
                    <span className="font-bold text-gray-900 text-sm font-inter">Notifications</span>
                    {unreadCount > 0 && (
                      <button
                        onClick={() => markAllReadMutation.mutate()}
                        className="text-xs text-indigo-600 font-bold hover:underline cursor-pointer"
                      >
                        Mark all as read
                      </button>
                    )}
                  </div>
                  <div className="flex-1 overflow-y-auto divide-y divide-gray-50">
                    {notifications.length === 0 ? (
                      <div className="py-8 text-center text-xs text-gray-500 font-inter">No recent notifications.</div>
                    ) : (
                      notifications.map((notif) => (
                        <div key={notif.id} className={`p-4 hover:bg-gray-50 transition-colors ${!notif.isRead ? "bg-indigo-50/30" : ""}`}>
                          <p className="font-bold text-xs text-gray-800 font-inter">{notif.title}</p>
                          <p className="text-xs text-gray-600 font-inter mt-1">{notif.body}</p>
                          <span className="text-[10px] text-gray-400 font-inter mt-2 block">
                            {new Date(notif.createdAt).toLocaleDateString()}
                          </span>
                        </div>
                      ))
                    )}
                  </div>
                </div>
              )}
            </div>

            {/* Profile Initials Dropdown */}
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded-full bg-slate-900 border border-slate-800 text-white font-semibold flex items-center justify-center text-sm font-inter">
                {user?.name?.charAt(0).toUpperCase()}
              </div>
              <div className="text-left hidden md:block">
                <p className="text-xs font-bold text-gray-900 leading-none font-inter">{user?.name}</p>
                <p className="text-[10px] text-gray-500 mt-0.5 leading-none font-inter">{user?.email}</p>
              </div>
              <button
                onClick={handleLogout}
                className="p-1 hover:bg-red-50 text-gray-400 hover:text-red-600 border border-transparent hover:border-red-100 rounded-lg transition-colors cursor-pointer"
              >
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
              </button>
            </div>

          </div>
        </header>

        {/* PAGE SCREEN CONTENT */}
        <main className="flex-1 overflow-y-auto p-4 md:p-8">
          {children}
        </main>
      </div>

      {/* MOBILE DRAWER */}
      {mobileMenuOpen && (
        <div className="md:hidden fixed inset-0 z-50 flex">
          {/* Backdrop */}
          <div
            onClick={() => setMobileMenuOpen(false)}
            className="fixed inset-0 bg-slate-900/60 backdrop-blur-xs animate-in fade-in duration-200"
          />
          {/* Sidebar Drawer Panel */}
          <aside className="relative w-64 bg-slate-900 flex flex-col z-50 animate-in slide-in-from-left duration-200">
            <div className="h-16 px-6 flex items-center justify-between border-b border-slate-800">
              <span className="text-xl font-bold text-white tracking-wide font-inter">
                TeamFlow
              </span>
              <button
                onClick={() => setMobileMenuOpen(false)}
                className="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-slate-800 cursor-pointer"
              >
                <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <nav className="flex-1 px-4 py-6 space-y-1">
              {navLinks.map((link) => {
                const isSel = location.pathname === link.path;
                return (
                  <Link
                    key={link.name}
                    to={link.path}
                    onClick={() => setMobileMenuOpen(false)}
                    className={`flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-semibold transition-all font-inter ${
                      isSel
                        ? "bg-indigo-600 text-white shadow-md shadow-indigo-600/10"
                        : "text-slate-400 hover:bg-slate-800 hover:text-white"
                    }`}
                  >
                    {link.icon}
                    {link.name}
                  </Link>
                );
              })}
            </nav>
          </aside>
        </div>
      )}

      {/* Modals Mounting */}
      <CreateWorkspaceModal isOpen={createWsOpen} onClose={() => setCreateWsOpen(false)} />
      <EditWorkspaceModal isOpen={editWsOpen} onClose={() => setEditWsOpen(false)} />
      <WorkspaceMembersModal isOpen={membersWsOpen} onClose={() => setMembersWsOpen(false)} />
    </div>
  );
}
