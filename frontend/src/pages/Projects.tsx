import { useState } from "react";
import { useProjects } from "../hooks/useProjects";
import type { Project } from "../types/Project";
import CreateProjectModal from "../components/CreateProjectModel";
import { useNavigate } from "react-router-dom";
import { useUpdateProject } from "../hooks/useUpdateProject";
import { useDeleteProject } from "../hooks/useDeleteProject";

export default function Projects() {
  const { data, isLoading, error } = useProjects();
  const [open, setOpen] = useState(false);
  const [editingProject, setEditingProject] = useState<Project | null>(null);
  const [deleteProject, setDeleteProject] = useState<Project | null>(null);
  const [editName, setEditName] = useState("");
  const navigate = useNavigate();

  const updateMutation = useUpdateProject();
  const deleteMutation = useDeleteProject();

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

  const projects = data || [];

  const saveProject = async () => {
    if (!editingProject) return;
    await updateMutation.mutateAsync({
      id: editingProject.id,
      name: editName,
    });
    setEditingProject(null);
  };

  const confirmDelete = async () => {
    if (!deleteProject) return;
    await deleteMutation.mutateAsync(deleteProject.id);
    setDeleteProject(null);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-4xl font-bold text-gray-900 mb-2">
                Projects
              </h1>
              <p className="text-gray-600">Manage and organize your projects</p>
            </div>
            <button
              onClick={() => setOpen(true)}
              className="flex items-center gap-2 px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-200 transition-all shadow-sm hover:shadow-md"
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
              Create Project
            </button>
          </div>
        </div>

        {/* Projects Grid */}
        {projects.length === 0 ? (
          <div className="bg-white rounded-xl shadow-sm p-12 text-center border border-gray-200">
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
                d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
              />
            </svg>
            <h3 className="text-lg font-medium text-gray-900 mb-2">
              No projects yet
            </h3>
            <p className="text-gray-500 mb-6">
              Get started by creating your first project
            </p>
            <button
              onClick={() => setOpen(true)}
              className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-200 transition-all"
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
              Create Your First Project
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {projects.map((project: Project) => (
              <div
                key={project.id}
                className="group bg-white rounded-xl shadow-sm p-6 border border-gray-200 hover:shadow-lg hover:border-blue-300 transition-all"
              >
                <div className="flex items-start justify-between mb-4">
                  <div
                    className="p-3 bg-blue-100 rounded-lg group-hover:bg-blue-200 transition-colors cursor-pointer"
                    onClick={() => navigate(`/projects/${project.id}`)}
                  >
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

                  {/* Edit & Delete */}
                  <div className="flex gap-3 opacity-0 group-hover:opacity-100 transition">
                    <button
                      onClick={() => {
                        setEditingProject(project);
                        setEditName(project.name);
                      }}
                      className="text-blue-600 hover:text-blue-800"
                    >
                      ✏️
                    </button>
                    <button
                      onClick={() => setDeleteProject(project)}
                      className="text-red-600 hover:text-red-800"
                    >
                      🗑️
                    </button>
                  </div>
                </div>

                <h3
                  onClick={() => navigate(`/projects/${project.id}`)}
                  className="text-lg font-semibold text-gray-900 mb-4 group-hover:text-blue-600 transition-colors cursor-pointer"
                >
                  {project.name}
                </h3>

                <div className="flex items-center gap-4 pt-4 border-t border-gray-100">
                  <div className="flex items-center gap-2 text-sm text-gray-500">
                    <span>{project._count?.tasks || 0} tasks</span>
                  </div>
                  <div className="text-sm text-gray-500">
                    {new Date(project.createdAt).toLocaleDateString()}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Stats (unchanged) */}
        {projects.length > 0 && (
          <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
            {/* same stats block you already have */}
          </div>
        )}
      </div>

      {/* Create Modal */}
      {open && <CreateProjectModal onClose={() => setOpen(false)} />}

      {/* Edit Modal */}
      {editingProject && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center">
          <div className="bg-white p-6 rounded-xl shadow-md w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4">Edit Project</h2>
            <input
              className="border p-2 rounded w-full mb-4"
              value={editName}
              onChange={(e) => setEditName(e.target.value)}
            />
            <div className="flex justify-end gap-3">
              <button
                onClick={() => setEditingProject(null)}
                className="px-4 py-2 border rounded"
              >
                Cancel
              </button>
              <button
                onClick={saveProject}
                className="px-4 py-2 bg-blue-600 text-white rounded"
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirm */}
      {deleteProject && (
        <div className="fixed inset-0 bg-black/40 flex items-center justify-center">
          <div className="bg-white p-6 rounded-xl shadow-md w-full max-w-md">
            <h2 className="text-xl font-semibold mb-4 text-red-600">
              Delete Project?
            </h2>
            <p className="mb-6">
              This will permanently delete{" "}
              <strong>{deleteProject.name}</strong> and all tasks.
            </p>

            <div className="flex justify-end gap-3">
              <button
                onClick={() => setDeleteProject(null)}
                className="px-4 py-2 border rounded"
              >
                Cancel
              </button>
              <button
                onClick={confirmDelete}
                className="px-4 py-2 bg-red-600 text-white rounded"
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
