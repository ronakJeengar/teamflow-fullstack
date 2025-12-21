import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useTasks } from "../hooks/useTasks";
import { useCreateTask } from "../hooks/useCreateTask";
import { useUpdateTask } from "../hooks/useUpdateTask";
import { useDeleteTask } from "../hooks/useDeleteTask";
import type { Task } from "../types/Task";
import { AxiosError } from "axios";

export default function Tasks() {
  const { projectId } = useParams<{ projectId: string }>();
  const navigate = useNavigate();

  const { data, isLoading, error } = useTasks(projectId as string);
  const createTask = useCreateTask(projectId as string);
  const updateTask = useUpdateTask(projectId as string);
  const deleteTask = useDeleteTask(projectId as string);

  const [newTitle, setNewTitle] = useState("");
  const [newDescription, setNewDescription] = useState("");

  if (!projectId) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md">
          <p className="text-gray-600">Project not found.</p>
        </div>
      </div>
    );
  }

  // Handle authentication error
  if (error) {
    const isAuthError =
      error instanceof AxiosError && error.response?.status === 401;

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
              {isAuthError ? "Authentication Required" : "Error Loading Tasks"}
            </h2>
            <p className="text-gray-600 mb-6">
              {isAuthError
                ? "Your session has expired. Please log in again."
                : "Failed to load tasks. Please try again."}
            </p>
            <button
              onClick={() => {
                if (isAuthError) {
                  localStorage.removeItem("token");
                  navigate("/login");
                } else {
                  window.location.reload();
                }
              }}
              className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-200 transition-all"
            >
              {isAuthError ? "Go to Login" : "Retry"}
            </button>
          </div>
        </div>
      </div>
    );
  }

  const addTask = async () => {
    if (!newTitle.trim()) return;
    await createTask.mutateAsync({
      title: newTitle,
      description: newDescription || undefined, // Only send if not empty
    });
    setNewTitle("");
    setNewDescription("");
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      addTask();
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading tasks...</p>
        </div>
      </div>
    );
  }

  const tasks = data?.data || [];

  const getStatusColor = (status: string) => {
    switch (status) {
      case "TODO":
        return "bg-gray-100 text-gray-700";
      case "IN_PROGRESS":
        return "bg-blue-100 text-blue-700";
      case "DONE":
        return "bg-green-100 text-green-700";
      default:
        return "bg-gray-100 text-gray-700";
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case "TODO":
        return "To Do";
      case "IN_PROGRESS":
        return "In Progress";
      case "DONE":
        return "Done";
      default:
        return status;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 py-8 px-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Tasks</h1>
          <p className="text-gray-600">Manage your project tasks efficiently</p>
        </div>

        {/* Add Task Card */}
        <div className="bg-white rounded-xl shadow-sm p-6 mb-6 border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Create New Task
          </h2>
          <div className="space-y-3">
            <input
              type="text"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="Task title..."
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all"
            />
            <textarea
              value={newDescription}
              onChange={(e) => setNewDescription(e.target.value)}
              placeholder="Task description (optional)..."
              rows={3}
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all resize-none"
            />
            <button
              onClick={addTask}
              disabled={!newTitle.trim() || createTask.isPending}
              className="w-full px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-200 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
            >
              {createTask.isPending ? "Adding..." : "Add Task"}
            </button>
          </div>
        </div>

        {/* Tasks List */}
        <div className="space-y-3">
          {tasks.length === 0 ? (
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
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                />
              </svg>
              <h3 className="text-lg font-medium text-gray-900 mb-2">
                No tasks yet
              </h3>
              <p className="text-gray-500">
                Get started by creating your first task above
              </p>
            </div>
          ) : (
            tasks.map((task: Task) => (
              <div
                key={task.id}
                className="bg-white rounded-xl shadow-sm p-6 border border-gray-200 hover:shadow-md transition-shadow"
              >
                <div className="flex items-start justify-between gap-4 mb-3">
                  <div className="flex-1 min-w-0">
                    <h3 className="text-lg font-semibold text-gray-900 mb-2">
                      {task.title}
                    </h3>
                    {task.description && (
                      <p className="text-gray-600 text-sm mb-3 whitespace-pre-wrap">
                        {task.description}
                      </p>
                    )}
                    <span
                      className={`inline-block px-3 py-1 rounded-full text-sm font-medium ${getStatusColor(
                        task.status
                      )}`}
                    >
                      {getStatusLabel(task.status)}
                    </span>
                  </div>
                </div>
                <div className="flex gap-2 flex-wrap">
                  {task.status !== "IN_PROGRESS" && (
                    <button
                      onClick={() =>
                        updateTask.mutate({
                          id: task.id,
                          status: "IN_PROGRESS",
                        })
                      }
                      disabled={updateTask.isPending}
                      className="px-4 py-2 bg-blue-50 text-blue-700 font-medium rounded-lg hover:bg-blue-100 focus:ring-4 focus:ring-blue-200 disabled:opacity-50 transition-all"
                    >
                      Start
                    </button>
                  )}
                  {task.status !== "DONE" && (
                    <button
                      onClick={() =>
                        updateTask.mutate({ id: task.id, status: "DONE" })
                      }
                      disabled={updateTask.isPending}
                      className="px-4 py-2 bg-green-50 text-green-700 font-medium rounded-lg hover:bg-green-100 focus:ring-4 focus:ring-green-200 disabled:opacity-50 transition-all"
                    >
                      Complete
                    </button>
                  )}
                  <button
                    onClick={() => deleteTask.mutate(task.id)}
                    disabled={deleteTask.isPending}
                    className="px-4 py-2 bg-red-50 text-red-700 font-medium rounded-lg hover:bg-red-100 focus:ring-4 focus:ring-red-200 disabled:opacity-50 transition-all"
                  >
                    Delete
                  </button>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Task Stats */}
        {tasks.length > 0 && (
          <div className="mt-6 bg-white rounded-xl shadow-sm p-6 border border-gray-200">
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <p className="text-2xl font-bold text-gray-900">
                  {tasks.filter((t: Task) => t.status === "TODO").length}
                </p>
                <p className="text-sm text-gray-600">To Do</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-blue-600">
                  {tasks.filter((t: Task) => t.status === "IN_PROGRESS").length}
                </p>
                <p className="text-sm text-gray-600">In Progress</p>
              </div>
              <div>
                <p className="text-2xl font-bold text-green-600">
                  {tasks.filter((t: Task) => t.status === "DONE").length}
                </p>
                <p className="text-sm text-gray-600">Completed</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
