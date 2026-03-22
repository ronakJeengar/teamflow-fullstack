import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { useTeams } from "../hooks/useTeams"; // custom hook similar to useProjects
import type { Team } from "../types/Team";
import CreateTeamModal from "../components/CreateTeamModel";
import { useUpdateTeam } from "../hooks/useUpdateTeam";
import { useDeleteTeam } from "../hooks/useDeleteTeam";
import type { TeamMember } from "../types/TeamMember";
import type { Project } from "../types/Project";

export default function Teams() {
  const { user, logout } = useAuth();
  const { data, isLoading, error } = useTeams();
  const [open, setOpen] = useState(false);
  const [editingTeam, setEditingTeam] = useState<Team | null>(null);
  const [deleteTeam, setDeleteTeam] = useState<Team | null>(null);
  const [editName, setEditName] = useState("");
  const [editDescription, setEditDescription] = useState("");
  const navigate = useNavigate();

  const updateMutation = useUpdateTeam();
  const deleteMutation = useDeleteTeam();

  const handleLogout = async () => {
    try {
      await logout();
      navigate("/login", { replace: true });
    } catch (err) {
      console.error("Logout failed:", err);
    }
  };

  const saveTeam = async () => {
    if (!editingTeam) return;
    // call updateTeam mutation hook
    await updateMutation.mutateAsync({
      id: editingTeam.id,
      name: editName,
      //   description: editDescription,
    });
    setEditingTeam(null);
  };

  const confirmDelete = async () => {
    if (!deleteTeam) return;
    // call deleteTeam mutation hook
    await deleteMutation.mutateAsync(deleteTeam.id);
    setDeleteTeam(null);
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading projects...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md max-w-md">
          <div className="text-center">
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
            <h2 className="text-xl font-semibold text-gray-900 mb-2">
              Error Loading Projects
            </h2>
            <p className="text-gray-600 mb-6">
              Failed to load projects. Please try again.
            </p>
            <button
              onClick={() => window.location.reload()}
              className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-200 transition-all"
            >
              Retry
            </button>
          </div>
        </div>
      </div>
    );
  }

  const teams: Team[] = data || [];

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-4xl font-bold">Teams</h1>
          <p className="text-gray-600">Manage your teams and members</p>
        </div>
        <div className="flex gap-4">
          {/* User info */}
          <div className="flex items-center gap-2 bg-white p-2 rounded shadow">
            <div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center text-white font-semibold">
              {user?.name?.charAt(0).toUpperCase() || "U"}
            </div>
            <div className="text-sm">
              <p>{user?.name}</p>
              <p className="text-gray-500">{user?.email}</p>
            </div>
          </div>
          {/* Create Team */}
          <button
            onClick={() => setOpen(true)}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            + Create Team
          </button>
          {/* Logout */}
          <button
            onClick={handleLogout}
            className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
          >
            Logout
          </button>
        </div>
      </div>

      {/* Teams Grid */}
      {teams.length === 0 ? (
        <div className="text-center bg-white p-12 rounded shadow">
          <p>No teams yet</p>
          <button
            onClick={() => setOpen(true)}
            className="mt-4 px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Create Your First Team
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {teams.map((team: Team) => (
            <div
              key={team.id}
              className="bg-white p-6 rounded-xl shadow-sm hover:shadow-lg cursor-pointer border border-gray-200"
            >
              <div className="flex justify-between items-start mb-4">
                <div onClick={() => navigate(`/teams/${team.id}`)}>
                  <h3 className="text-lg font-semibold">{team.name}</h3>
                  <p className="text-gray-500">{team.description}</p>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => {
                      setEditingTeam(team);
                      setEditName(team.name);
                      setEditDescription(team.description || "");
                    }}
                    className="text-blue-600 hover:text-blue-800"
                  >
                    ✏️
                  </button>
                  <button
                    onClick={() => setDeleteTeam(team)}
                    className="text-red-600 hover:text-red-800"
                  >
                    🗑️
                  </button>
                </div>
              </div>

              {/* Stats */}
              <div className="flex justify-between text-sm text-gray-500 pt-2 border-t border-gray-100">
                {/* <span>{team.members!.length} members</span>
                <span>{team.projects!.length} projects</span> */}
                {(team.members || []).map((member: TeamMember) => (
                  <p key={member.id}>{member.user?.name}</p>
                ))}
                {(team.projects || []).map((project: Project) => (
                  <p key={project.id}>{project.name}</p>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Create Team Modal */}
      {open && <CreateTeamModal onClose={() => setOpen(false)} />}

      {/* Edit Team Modal */}
      {editingTeam && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl shadow-md w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4">Edit Team</h2>
            <input
              className="border p-2 rounded w-full mb-4"
              value={editName}
              onChange={(e) => setEditName(e.target.value)}
              placeholder="Team Name"
            />
            <textarea
              className="border p-2 rounded w-full mb-4"
              value={editDescription}
              onChange={(e) => setEditDescription(e.target.value)}
              placeholder="Description"
            />
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setEditingTeam(null)}
                className="px-4 py-2 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={saveTeam}
                className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirm Modal */}
      {deleteTeam && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-xl shadow-md w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4 text-red-600">
              Delete Team?
            </h2>
            <p className="mb-6">
              This will permanently delete <strong>{deleteTeam.name}</strong>{" "}
              and all projects.
            </p>
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setDeleteTeam(null)}
                className="px-4 py-2 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={confirmDelete}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
