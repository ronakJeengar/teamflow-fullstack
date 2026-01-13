import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useTeam } from "../hooks/useTeam";
import { useAuth } from "../auth/AuthContext";
import type { TeamMember } from "../types/TeamMember";
import { useTeamMembers } from "../hooks/useTeamMembers";
import { useRemoveMember } from "../hooks/useRemoveMember";
import { useUpdateMemberRole } from "../hooks/useUpdateMemberRole";
import type { Project } from "../types/Project";
import { useUpdateProject } from "../hooks/useUpdateProject";
import { useDeleteProject } from "../hooks/useDeleteProject";
import CreateProjectModal from "../components/CreateProjectModel";
import InviteMemberModal from "../components/TeamInviteModel";

export default function TeamDetails() {
  const { teamId } = useParams<{ teamId: string }>();
  const navigate = useNavigate();
  const { user } = useAuth();

  const [editingProject, setEditingProject] = useState<Project | null>(null);
  const [deleteProject, setDeleteProject] = useState<Project | null>(null);
  const [editName, setEditName] = useState("");

  const [activeTab, setActiveTab] = useState<
    "overview" | "projects" | "members"
  >("overview");
  const [openCreateProject, setOpenCreateProject] = useState(false);
  const [openInviteModal, setOpenInviteModal] = useState(false);

  const { data: members, isLoading: membersLoading } = useTeamMembers(teamId!);

  const removeMemberMutation = useRemoveMember(teamId!);
  const updateRoleMutation = useUpdateMemberRole(teamId!);

  const { data: team, isLoading, error } = useTeam(teamId!);

  const updateMutation = useUpdateProject(teamId!);
  const deleteMutation = useDeleteProject(teamId!);

  // Loading state
  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading team details...</p>
        </div>
      </div>
    );
  }

  // Error state
  if (error || !team) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md max-w-md text-center">
          <svg
            className="mx-auto h-12 w-12 text-red-500 mb-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
          <h2 className="text-xl font-semibold text-red-600 mb-2">
            Unable to Access Team
          </h2>
          <p className="text-gray-600 mb-6">
            You may not have permission or the team does not exist.
          </p>
          <button
            onClick={() => navigate("/teams")}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all"
          >
            Back to Teams
          </button>
        </div>
      </div>
    );
  }

  const currentUserMember = team.members.find(
    (m: TeamMember) => m.userId === user?.id
  );
  const isOwner = team.ownerId === user?.id;
  const isAdmin = currentUserMember?.role === "ADMIN" || isOwner;

  const saveProject = async () => {
    if (!editingProject || !editName.trim()) return;
    try {
      await updateMutation.mutateAsync({
        id: editingProject.id,
        name: editName.trim(),
      });
      setEditingProject(null);
      setEditName("");
    } catch (error) {
      console.error("Failed to update project:", error);
      // Optionally show an error notification
    }
  };

  const confirmDelete = async () => {
    if (!deleteProject) return;
    try {
      await deleteMutation.mutateAsync(deleteProject.id);
      setDeleteProject(null);
    } catch (error) {
      console.error("Failed to delete project:", error);
      // Optionally show an error notification
    }
  };

  const handleRemoveMember = async (memberId: string, memberName: string) => {
    if (window.confirm(`Remove ${memberName} from the team?`)) {
      try {
        await removeMemberMutation.mutateAsync(memberId);
      } catch (error) {
        console.error("Failed to remove member:", error);
        // Optionally show an error notification
      }
    }
  };

  const handleUpdateRole = async (memberId: string, newRole: string) => {
    try {
      await updateRoleMutation.mutateAsync({
        memberId,
        role: newRole,
      });
    } catch (error) {
      console.error("Failed to update member role:", error);
      // Optionally show an error notification
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header Section */}
        <div className="bg-white rounded-xl shadow-sm p-8 mb-6 border border-gray-200">
          <div className="flex items-start justify-between mb-6">
            <div className="flex items-center gap-4">
              <button
                onClick={() => navigate("/teams")}
                className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                title="Back to Teams"
                aria-label="Back to Teams"
              >
                <svg
                  className="w-6 h-6 text-gray-600"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M15 19l-7-7 7-7"
                  />
                </svg>
              </button>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">
                  {team.name}
                </h1>
                {team.description && (
                  <p className="text-gray-600 mt-2">{team.description}</p>
                )}
              </div>
            </div>
            {isOwner && (
              <button
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all flex items-center gap-2"
                onClick={() => {
                  // Add invite functionality here
                  console.log("Invite members");
                }}
              >
                <svg
                  className="w-5 h-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                  />
                </svg>
                Invite Members
              </button>
            )}
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-blue-50 rounded-lg p-4 border border-blue-100">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <svg
                    className="w-6 h-6 text-blue-600"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                    />
                  </svg>
                </div>
                <div>
                  <p className="text-2xl font-bold text-blue-900">
                    {team.projects?.length || 0}
                  </p>
                  <p className="text-sm text-blue-700">Projects</p>
                </div>
              </div>
            </div>

            <div className="bg-green-50 rounded-lg p-4 border border-green-100">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-green-100 rounded-lg">
                  <svg
                    className="w-6 h-6 text-green-600"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                    />
                  </svg>
                </div>
                <div>
                  <p className="text-2xl font-bold text-green-900">
                    {team.members?.length || 0}
                  </p>
                  <p className="text-sm text-green-700">Members</p>
                </div>
              </div>
            </div>

            <div className="bg-purple-50 rounded-lg p-4 border border-purple-100">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-purple-100 rounded-lg">
                  <svg
                    className="w-6 h-6 text-purple-600"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                    />
                  </svg>
                </div>
                <div>
                  <p className="text-2xl font-bold text-purple-900">
                    {team.projects?.reduce(
                      (sum: number, p: Project) => sum + (p._count?.tasks || 0),
                      0
                    ) || 0}
                  </p>
                  <p className="text-sm text-purple-700">Total Tasks</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Tabs Navigation */}
        <div className="bg-white rounded-xl shadow-sm mb-6 border border-gray-200">
          <div className="flex border-b border-gray-200">
            <button
              onClick={() => setActiveTab("overview")}
              className={`flex-1 px-6 py-4 font-medium text-sm transition-all ${
                activeTab === "overview"
                  ? "text-blue-600 border-b-2 border-blue-600 bg-blue-50"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              }`}
              aria-label="Overview tab"
            >
              <div className="flex items-center justify-center gap-2">
                <svg
                  className="w-5 h-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                  />
                </svg>
                Overview
              </div>
            </button>
            <button
              onClick={() => setActiveTab("projects")}
              className={`flex-1 px-6 py-4 font-medium text-sm transition-all ${
                activeTab === "projects"
                  ? "text-blue-600 border-b-2 border-blue-600 bg-blue-50"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              }`}
              aria-label="Projects tab"
            >
              <div className="flex items-center justify-center gap-2">
                <svg
                  className="w-5 h-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                  />
                </svg>
                Projects ({team.projects?.length || 0})
              </div>
            </button>
            <button
              onClick={() => setActiveTab("members")}
              className={`flex-1 px-6 py-4 font-medium text-sm transition-all ${
                activeTab === "members"
                  ? "text-blue-600 border-b-2 border-blue-600 bg-blue-50"
                  : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              }`}
              aria-label="Members tab"
            >
              <div className="flex items-center justify-center gap-2">
                <svg
                  className="w-5 h-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                  />
                </svg>
                Members ({team.members?.length || 0})
              </div>
            </button>
          </div>
        </div>

        {/* Tab Content */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
          {/* Overview Tab */}
          {activeTab === "overview" && (
            <div className="space-y-6">
              <div>
                <h2 className="text-2xl font-bold mb-4">Team Overview</h2>
                <p className="text-gray-600 mb-6">
                  Welcome to {team.name}! Here's a quick overview of your team's
                  activity.
                </p>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Recent Projects */}
                <div className="border border-gray-200 rounded-lg p-4">
                  <h3 className="font-semibold text-lg mb-3 flex items-center gap-2">
                    <svg
                      className="w-5 h-5 text-blue-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                      />
                    </svg>
                    Recent Projects
                  </h3>
                  {team.projects && team.projects.length > 0 ? (
                    <ul className="space-y-2">
                      {team.projects.slice(0, 3).map((project: Project) => (
                        <li
                          key={project.id}
                          className="flex justify-between items-center p-2 hover:bg-gray-50 rounded cursor-pointer transition-colors"
                          onClick={() => navigate(`/projects/${project.id}`)}
                        >
                          <span className="font-medium">{project.name}</span>
                          <span className="text-sm text-gray-500">
                            {project._count?.tasks || 0} tasks
                          </span>
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="text-gray-500 text-sm">No projects yet</p>
                  )}
                </div>

                {/* Team Members Preview */}
                <div className="border border-gray-200 rounded-lg p-4">
                  <h3 className="font-semibold text-lg mb-3 flex items-center gap-2">
                    <svg
                      className="w-5 h-5 text-green-600"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                      />
                    </svg>
                    Team Members
                  </h3>
                  {team.members && team.members.length > 0 ? (
                    <ul className="space-y-2">
                      {team.members.slice(0, 3).map((member: TeamMember) => (
                        <li
                          key={member.id}
                          className="flex justify-between items-center p-2 hover:bg-gray-50 rounded transition-colors"
                        >
                          <div className="flex items-center gap-2">
                            <div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white text-sm font-semibold">
                              {member.user?.name?.charAt(0).toUpperCase() ||
                                "U"}
                            </div>
                            <span className="font-medium">
                              {member.user?.name}
                            </span>
                          </div>
                          <span className="text-xs bg-gray-100 px-2 py-1 rounded">
                            {member.role}
                          </span>
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="text-gray-500 text-sm">No members yet</p>
                  )}
                </div>
              </div>
            </div>
          )}

          {/* Projects Tab */}
          {activeTab === "projects" && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold">Team Projects</h2>
                {isAdmin && (
                  <button
                    onClick={() => setOpenCreateProject(true)}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all flex items-center gap-2"
                  >
                    <svg
                      className="w-5 h-5"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M12 4v16m8-8H4"
                      />
                    </svg>
                    New Project
                  </button>
                )}
              </div>

              {!team.projects || team.projects.length === 0 ? (
                <div className="text-center py-12">
                  <svg
                    className="mx-auto h-16 w-16 text-gray-400 mb-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                    />
                  </svg>
                  <h3 className="text-lg font-medium text-gray-900 mb-2">
                    No projects yet
                  </h3>
                  <p className="text-gray-500 mb-6">
                    Get started by creating your first project
                  </p>
                  {isAdmin && (
                    <button
                      onClick={() => setOpenCreateProject(true)}
                      className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all"
                    >
                      Create Project
                    </button>
                  )}
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {team.projects.map((project: Project) => (
                    <div
                      key={project.id}
                      className="group border border-gray-200 rounded-lg p-6 hover:shadow-lg hover:border-blue-300 transition-all cursor-pointer"
                      onClick={() => navigate(`/projects/${project.id}`)}
                    >
                      <div className="flex items-start justify-between mb-4">
                        <div className="p-3 bg-blue-100 rounded-lg group-hover:bg-blue-200 transition-colors">
                          <svg
                            className="w-6 h-6 text-blue-600"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"
                            />
                          </svg>
                        </div>
                        {isAdmin && (
                          <div className="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                setEditingProject(project);
                                setEditName(project.name);
                              }}
                              className="text-blue-600 hover:text-blue-800 p-1"
                              title="Edit project"
                              aria-label="Edit project"
                            >
                              <svg
                                className="w-5 h-5"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth={2}
                                  d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                                />
                              </svg>
                            </button>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                setDeleteProject(project);
                              }}
                              className="text-red-600 hover:text-red-800 p-1"
                              title="Delete project"
                              aria-label="Delete project"
                            >
                              <svg
                                className="w-5 h-5"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke="currentColor"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth={2}
                                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                                />
                              </svg>
                            </button>
                          </div>
                        )}
                      </div>

                      <h3 className="text-lg font-semibold text-gray-900 mb-2 group-hover:text-blue-600 transition-colors">
                        {project.name}
                      </h3>

                      <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                        <div className="flex items-center gap-2 text-sm text-gray-500">
                          <svg
                            className="w-4 h-4"
                            fill="none"
                            viewBox="0 0 24 24"
                            stroke="currentColor"
                          >
                            <path
                              strokeLinecap="round"
                              strokeLinejoin="round"
                              strokeWidth={2}
                              d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                            />
                          </svg>
                          <span>{project._count?.tasks || 0} tasks</span>
                        </div>
                        <span className="text-xs text-gray-500">
                          {new Date(project.createdAt).toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Members Tab */}
          {activeTab === "members" && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold">Team Members</h2>
                {isOwner && (
                  <button
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-all flex items-center gap-2"
                    onClick={() => setOpenInviteModal(true)}
                  >
                    <svg
                      className="w-5 h-5"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"
                      />
                    </svg>
                    Invite Member
                  </button>
                )}
              </div>

              {membersLoading ? (
                <div className="text-center py-12">
                  <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="mt-4 text-gray-600">Loading members...</p>
                </div>
              ) : !members || members.length === 0 ? (
                <div className="text-center py-12">
                  <svg
                    className="mx-auto h-16 w-16 text-gray-400 mb-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"
                    />
                  </svg>
                  <h3 className="text-lg font-medium text-gray-900 mb-2">
                    No members yet
                  </h3>
                  <p className="text-gray-500">
                    Invite members to get started with team collaboration
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {members.map((member: TeamMember) => (
                    <div
                      key={member.id}
                      className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-all"
                    >
                      <div className="flex items-start gap-3">
                        <div className="w-12 h-12 bg-blue-600 rounded-full flex items-center justify-center text-white text-lg font-semibold flex-shrink-0">
                          {member.user?.name?.charAt(0).toUpperCase() || "U"}
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="font-semibold text-gray-900 truncate">
                            {member.user?.name}
                          </h3>
                          <p className="text-sm text-gray-500 truncate">
                            {member.user?.email}
                          </p>
                          <div className="mt-2">
                            {isOwner && member.userId !== user?.id ? (
                              <select
                                value={member.role}
                                onChange={(e) =>
                                  handleUpdateRole(member.id, e.target.value)
                                }
                                className="text-xs border border-gray-300 rounded px-2 py-1 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                onClick={(e) => e.stopPropagation()}
                              >
                                <option value="ADMIN">Admin</option>
                                <option value="MEMBER">Member</option>
                                <option value="VIEWER">Viewer</option>
                              </select>
                            ) : (
                              <span
                                className={`inline-block text-xs px-2 py-1 rounded ${
                                  member.role === "OWNER"
                                    ? "bg-purple-100 text-purple-700"
                                    : member.role === "ADMIN"
                                    ? "bg-blue-100 text-blue-700"
                                    : member.role === "MEMBER"
                                    ? "bg-green-100 text-green-700"
                                    : "bg-gray-100 text-gray-700"
                                }`}
                              >
                                {member.role}
                              </span>
                            )}
                          </div>
                        </div>
                        {isOwner && member.userId !== user?.id && (
                          <button
                            onClick={() =>
                              handleRemoveMember(
                                member.id,
                                member.user?.name || "this member"
                              )
                            }
                            className="text-red-600 hover:text-red-800 p-1 transition-colors"
                            title="Remove member"
                            aria-label="Remove member"
                          >
                            <svg
                              className="w-5 h-5"
                              fill="none"
                              viewBox="0 0 24 24"
                              stroke="currentColor"
                            >
                              <path
                                strokeLinecap="round"
                                strokeLinejoin="round"
                                strokeWidth={2}
                                d="M6 18L18 6M6 6l12 12"
                              />
                            </svg>
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Edit Project Modal */}
      {editingProject && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div className="bg-white p-6 rounded-xl shadow-md w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4">Edit Project</h2>
            <input
              className="border border-gray-300 p-2 rounded w-full mb-4 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={editName}
              onChange={(e) => setEditName(e.target.value)}
              placeholder="Project Name"
              autoFocus
              onKeyDown={(e) => {
                if (e.key === "Enter") saveProject();
                if (e.key === "Escape") {
                  setEditingProject(null);
                  setEditName("");
                }
              }}
            />
            <div className="flex justify-end gap-3">
              <button
                onClick={() => {
                  setEditingProject(null);
                  setEditName("");
                }}
                className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={saveProject}
                disabled={!editName.trim() || updateMutation.isPending}
                className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {updateMutation.isPending ? "Saving..." : "Save"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Project Confirm Modal */}
      {deleteProject && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50 p-4">
          <div className="bg-white p-6 rounded-xl shadow-md w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4 text-red-600">
              Delete Project?
            </h2>
            <p className="mb-6 text-gray-700">
              This will permanently delete{" "}
              <strong className="text-gray-900">{deleteProject.name}</strong>{" "}
              and all its tasks. This action cannot be undone.
            </p>
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setDeleteProject(null)}
                className="px-4 py-2 border border-gray-300 rounded hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={confirmDelete}
                disabled={deleteMutation.isPending}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {deleteMutation.isPending ? "Deleting..." : "Delete"}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Create Project Modal */}
      {openCreateProject && (
        <CreateProjectModal
          teamId={team.id}
          onClose={() => setOpenCreateProject(false)}
        />
      )}

      {openInviteModal && (
        <InviteMemberModal
          teamId={team.id}
          onClose={() => setOpenInviteModal(false)}
        />
      )}
    </div>
  );
}
