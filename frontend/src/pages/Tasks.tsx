import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useTasks } from "../hooks/useTasks";
import { useCreateTask } from "../hooks/useCreateTask";
import { useUpdateTask } from "../hooks/useUpdateTask";
import { useDeleteTask } from "../hooks/useDeleteTask";
import type { Task } from "../types/Task";
import { AxiosError } from "axios";
import { useToast } from "../context/useToast";
import ConfirmModal from "../components/ConfirmModel";

export default function Tasks() {
  const { projectId } = useParams<{ projectId: string }>();
  const navigate = useNavigate();
  const toast = useToast();

  const { data, isLoading, error } = useTasks(projectId as string);
  const createTask = useCreateTask(projectId as string);
  const updateTask = useUpdateTask(projectId as string);
  const deleteTask = useDeleteTask(projectId as string);

  const [newTitle, setNewTitle] = useState("");
  const [newDescription, setNewDescription] = useState("");

  const [editTask, setEditTask] = useState<Task | null>(null);
  const [confirmDelete, setConfirmDelete] = useState<Task | null>(null);

  if (!projectId) return <p>No Project</p>;

  if (error) {
    const isAuthError =
      error instanceof AxiosError && error.response?.status === 401;

    return (
      <div className="h-screen flex items-center justify-center">
        <div>
          <h2>{isAuthError ? "Login Required" : "Error loading tasks"}</h2>
          <button onClick={() => navigate("/login")}>Login</button>
        </div>
      </div>
    );
  }

  const addTask = async () => {
    if (!newTitle.trim()) return;

    await createTask.mutateAsync(
      {
        title: newTitle,
        description: newDescription || undefined,
      },
      {
        onSuccess: () => {
          toast.showToast("Task Created Successfully");
          setNewTitle("");
          setNewDescription("");
        },
        onError: () => toast.showToast("Failed to create task", "error"),
      }
    );
  };

  const saveEdit = async () => {
    if (!editTask) return;

    await updateTask.mutateAsync(
      {
        id: editTask.id,
        title: editTask.title,
        description: editTask.description,
        status: editTask.status,
      },
      {
        onSuccess: () => {
          toast.showToast("Task Updated Successfully");
          setEditTask(null);
        },
        onError: () => toast.showToast("Failed to update task", "error"),
      }
    );
  };

  const confirmDeleteTask = async () => {
    if (!confirmDelete) return;

    await deleteTask.mutateAsync(confirmDelete.id, {
      onSuccess: () => toast.showToast("Task Deleted"),
      onError: () => toast.showToast("Delete Failed", "error"),
    });

    setConfirmDelete(null);
  };

  if (isLoading)
    return (
      <div className="flex justify-center items-center h-screen">
        Loading...
      </div>
    );

  const tasks = data?.data || [];

  return (
    <div className="min-h-screen p-8">
      <h1 className="text-3xl font-bold mb-6">Tasks</h1>

      {/* CREATE TASK */}
      <div className="bg-white p-6 rounded-xl shadow mb-6">
        <input
          className="border w-full p-3 rounded mb-2"
          placeholder="Task title..."
          value={newTitle}
          onChange={(e) => setNewTitle(e.target.value)}
        />

        <textarea
          className="border w-full p-3 rounded mb-3"
          rows={3}
          placeholder="Description (optional)"
          value={newDescription}
          onChange={(e) => setNewDescription(e.target.value)}
        />

        <button
          onClick={addTask}
          className="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700"
        >
          {createTask.isPending ? "Adding..." : "Add Task"}
        </button>
      </div>

      {/* TASK LIST */}
      <div className="space-y-3">
        {tasks.map((task: Task) => (
          <div key={task.id} className="bg-white p-6 rounded-xl shadow border">
            {editTask?.id === task.id ? (
              <>
                <input
                  className="border w-full p-3 rounded mb-2"
                  value={editTask.title}
                  onChange={(e) =>
                    setEditTask({ ...editTask, title: e.target.value })
                  }
                />

                <textarea
                  className="border w-full p-3 rounded mb-3"
                  rows={3}
                  value={editTask.description || ""}
                  onChange={(e) =>
                    setEditTask({ ...editTask, description: e.target.value })
                  }
                />

                <select
                  className="border p-2 rounded mb-3"
                  value={editTask.status}
                  onChange={(e) =>
                    setEditTask({
                      ...editTask,
                      status: e.target.value as Task["status"],
                    })
                  }
                >
                  <option value="TODO">To Do</option>
                  <option value="IN_PROGRESS">In Progress</option>
                  <option value="DONE">Done</option>
                </select>

                <div className="flex gap-2">
                  <button
                    onClick={saveEdit}
                    className="px-4 py-2 rounded bg-green-600 text-white"
                  >
                    Save
                  </button>
                  <button
                    onClick={() => setEditTask(null)}
                    className="px-4 py-2 rounded border"
                  >
                    Cancel
                  </button>
                </div>
              </>
            ) : (
              <>
                <h2 className="text-xl font-semibold">{task.title}</h2>

                {task.description && (
                  <p className="text-gray-600 mb-2">{task.description}</p>
                )}

                <span className="px-3 py-1 bg-gray-200 rounded-full text-sm">
                  {task.status}
                </span>

                <div className="flex gap-2 mt-4">
                  <button
                    onClick={() => setEditTask(task)}
                    className="px-4 py-2 rounded bg-yellow-400"
                  >
                    Edit
                  </button>

                  <button
                    onClick={() => setConfirmDelete(task)}
                    className="px-4 py-2 rounded bg-red-500 text-white"
                  >
                    Delete
                  </button>
                </div>
              </>
            )}
          </div>
        ))}
      </div>

      {/* CONFIRM DELETE MODAL */}
      <ConfirmModal
        open={!!confirmDelete}
        title="Delete Task?"
        message="This action cannot be undone."
        onConfirm={confirmDeleteTask}
        onClose={() => setConfirmDelete(null)}
      />
    </div>
  );
}
