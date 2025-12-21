import { useState, useMemo } from "react";
import {
  DragDropContext,
  Droppable,
  Draggable,
  type DropResult,
} from "@hello-pangea/dnd";
import { useParams, useNavigate } from "react-router-dom";
import { useTasks } from "../hooks/useTasks";
import { useCreateTask } from "../hooks/useCreateTask";
import { useUpdateTask } from "../hooks/useUpdateTask";
import { useDeleteTask } from "../hooks/useDeleteTask";
import type { Task } from "../types/Task";
import { AxiosError } from "axios";
import { useToast } from "../context/useToast";
import ConfirmModal from "../components/ConfirmModel";

type TaskStatus = "TODO" | "IN_PROGRESS" | "DONE";

interface TaskColumns {
  TODO: Task[];
  IN_PROGRESS: Task[];
  DONE: Task[];
}

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

  // ✅ For optimistic updates - null means use server data
  const [optimisticBoard, setOptimisticBoard] = useState<TaskColumns | null>(
    null
  );

  // Memoize tasks for performance
  const tasks = useMemo(() => data?.data || [], [data]);

  // ✅ Compute board from tasks - this is the source of truth
  const serverBoard: TaskColumns = useMemo(
    () => ({
      TODO: tasks.filter((t: Task) => t.status === "TODO"),
      IN_PROGRESS: tasks.filter((t: Task) => t.status === "IN_PROGRESS"),
      DONE: tasks.filter((t: Task) => t.status === "DONE"),
    }),
    [tasks]
  );

  // ✅ Use optimistic board if available, otherwise use server board
  const board = optimisticBoard || serverBoard;

  if (!projectId) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="bg-white p-8 rounded-lg shadow-md">
          <p className="text-gray-600">Project not found.</p>
        </div>
      </div>
    );
  }

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
    if (!newTitle.trim()) {
      toast.showToast("Please enter a task title", "error");
      return;
    }

    try {
      await createTask.mutateAsync(
        {
          title: newTitle,
          description: newDescription || undefined,
        },
        {
          onSuccess: () => {
            toast.showToast("Task created successfully");
            setNewTitle("");
            setNewDescription("");
            // ✅ Clear optimistic state to show server data
            setOptimisticBoard(null);
          },
          onError: () => toast.showToast("Failed to create task", "error"),
        }
      );
    } catch (err) {
      console.error("Error creating task:", err);
    }
  };

  const saveEdit = async () => {
    if (!editTask) return;

    if (!editTask.title.trim()) {
      toast.showToast("Task title cannot be empty", "error");
      return;
    }

    try {
      await updateTask.mutateAsync(
        {
          id: editTask.id,
          title: editTask.title,
          description: editTask.description,
          status: editTask.status,
        },
        {
          onSuccess: () => {
            toast.showToast("Task updated successfully");
            setEditTask(null);
            // ✅ Clear optimistic state
            setOptimisticBoard(null);
          },
          onError: () => toast.showToast("Failed to update task", "error"),
        }
      );
    } catch (err) {
      console.error("Error updating task:", err);
    }
  };

  const confirmDeleteTask = async () => {
    if (!confirmDelete) return;

    try {
      await deleteTask.mutateAsync(confirmDelete.id, {
        onSuccess: () => {
          toast.showToast("Task deleted");
          // ✅ Clear optimistic state
          setOptimisticBoard(null);
        },
        onError: () => toast.showToast("Delete failed", "error"),
      });

      setConfirmDelete(null);
    } catch (err) {
      console.error("Error deleting task:", err);
    }
  };

  // ✅ Optimistic drag handler with instant UI update
  const handleDragEnd = (result: DropResult) => {
    const { destination, source } = result;

    if (!destination) return;

    // Same position? Do nothing
    if (
      destination.droppableId === source.droppableId &&
      destination.index === source.index
    ) {
      return;
    }

    const sourceCol = source.droppableId as TaskStatus;
    const destCol = destination.droppableId as TaskStatus;

    // ✅ Create optimistic board update
    const newBoard = structuredClone(board);
    const [movedTask] = newBoard[sourceCol].splice(source.index, 1);
    movedTask.status = destCol;
    newBoard[destCol].splice(destination.index, 0, movedTask);

    // ✅ Set optimistic state immediately
    setOptimisticBoard(newBoard);

    // ✅ Then sync with server
    updateTask.mutate(
      {
        id: movedTask.id,
        title: movedTask.title,
        description: movedTask.description,
        status: destCol,
      },
      {
        onSuccess: () => {
          toast.showToast("Task moved");
          // ✅ Clear optimistic state to show server data
          setOptimisticBoard(null);
        },
        onError: () => {
          toast.showToast("Move failed, reverting", "error");
          // ✅ Clear optimistic state to revert to server data
          setOptimisticBoard(null);
        },
      }
    );
  };

  const handleKeyPress = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      addTask();
    }
  };

  // ✅ Edit mode keyboard shortcuts
  const handleEditKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      saveEdit();
    } else if (e.key === "Escape") {
      setEditTask(null);
    }
  };

  // ✅ Loading skeleton instead of spinner
  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-4 sm:p-8">
        <div className="max-w-7xl mx-auto">
          <div className="mb-8">
            <div className="h-10 w-32 bg-gray-200 rounded animate-pulse mb-2"></div>
            <div className="h-4 w-64 bg-gray-200 rounded animate-pulse"></div>
          </div>
          <div className="bg-white p-6 rounded-xl shadow-sm mb-6 border border-gray-200">
            <div className="h-12 bg-gray-200 rounded animate-pulse mb-3"></div>
            <div className="h-24 bg-gray-200 rounded animate-pulse mb-3"></div>
            <div className="h-12 bg-gray-200 rounded animate-pulse"></div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[1, 2, 3].map((i) => (
              <div key={i} className="bg-gray-100 p-4 rounded-xl min-h-[500px]">
                <div className="h-6 w-32 bg-gray-200 rounded animate-pulse mb-4"></div>
                {[1, 2, 3].map((j) => (
                  <div
                    key={j}
                    className="bg-white p-4 rounded-xl mb-3 h-24 animate-pulse"
                  ></div>
                ))}
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  const columnConfig = [
    { id: "TODO" as TaskStatus, title: "📝 To Do", color: "bg-gray-100" },
    {
      id: "IN_PROGRESS" as TaskStatus,
      title: "🚧 In Progress",
      color: "bg-blue-50",
    },
    { id: "DONE" as TaskStatus, title: "✅ Done", color: "bg-green-50" },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-4 sm:p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center gap-4 mb-2">
            <button
              onClick={() => navigate("/projects")}
              className="p-2 hover:bg-white rounded-lg transition-colors"
              aria-label="Back to projects"
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
            <h1 className="text-4xl font-bold text-gray-900">Tasks</h1>
          </div>
          <p className="text-gray-600 ml-14">
            Drag and drop tasks between columns
          </p>
        </div>

        {/* Create Task Card */}
        <div className="bg-white p-6 rounded-xl shadow-sm mb-6 border border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">
            Create New Task
          </h2>
          <div className="space-y-3">
            <input
              type="text"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all"
              placeholder="Task title..."
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              onKeyPress={handleKeyPress}
              aria-label="Task title"
            />

            <textarea
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none transition-all resize-none"
              rows={3}
              placeholder="Task description (optional)..."
              value={newDescription}
              onChange={(e) => setNewDescription(e.target.value)}
              aria-label="Task description"
            />

            <button
              onClick={addTask}
              disabled={!newTitle.trim() || createTask.isPending}
              className="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-200 disabled:opacity-50 disabled:cursor-not-allowed transition-all font-medium"
            >
              {createTask.isPending ? "Adding..." : "Add Task"}
            </button>
          </div>
        </div>

        {/* Task Board */}
        <DragDropContext onDragEnd={handleDragEnd}>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {columnConfig.map((column) => (
              <div
                key={column.id}
                className={`${column.color} p-4 rounded-xl min-h-[500px]`}
              >
                {/* ✅ Column Header - Outside Droppable */}
                <div className="flex items-center justify-between mb-4">
                  <h2 className="font-bold text-lg text-gray-900">
                    {column.title}
                  </h2>
                  <span className="bg-white px-3 py-1 rounded-full text-sm font-medium text-gray-600 shadow-sm">
                    {board[column.id].length}
                  </span>
                </div>

                {/* ✅ Droppable Area - Only for tasks */}
                <Droppable droppableId={column.id}>
                  {(provided, snapshot) => (
                    <div
                      ref={provided.innerRef}
                      {...provided.droppableProps}
                      className={`space-y-3 min-h-[400px] transition-colors rounded-lg ${
                        snapshot.isDraggingOver
                          ? "bg-blue-100 bg-opacity-50"
                          : ""
                      }`}
                    >
                      {board[column.id].map((task: Task, index: number) => (
                        <Draggable
                          draggableId={task.id}
                          index={index}
                          key={task.id}
                          isDragDisabled={editTask?.id === task.id}
                        >
                          {(provided, snapshot) => (
                            <div
                              className={`group bg-white p-4 rounded-xl shadow-sm border border-gray-200 transition-all ${
                                snapshot.isDragging
                                  ? "shadow-2xl ring-2 ring-blue-500 scale-105"
                                  : "hover:shadow-md"
                              }`}
                              ref={provided.innerRef}
                              {...provided.draggableProps}
                              {...provided.dragHandleProps}
                              role="button"
                              aria-grabbed={snapshot.isDragging}
                              tabIndex={0}
                            >
                              {editTask?.id === task.id ? (
                                <>
                                  <input
                                    type="text"
                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg mb-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none"
                                    value={editTask.title}
                                    onChange={(e) =>
                                      setEditTask({
                                        ...editTask,
                                        title: e.target.value,
                                      })
                                    }
                                    onKeyDown={handleEditKeyDown}
                                    autoFocus
                                    aria-label="Edit task title"
                                  />

                                  <textarea
                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg mb-3 focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none resize-none"
                                    rows={3}
                                    value={editTask.description || ""}
                                    onChange={(e) =>
                                      setEditTask({
                                        ...editTask,
                                        description: e.target.value,
                                      })
                                    }
                                    onKeyDown={handleEditKeyDown}
                                    aria-label="Edit task description"
                                  />

                                  <div className="text-xs text-gray-500 mb-2">
                                    Press Enter to save, Escape to cancel
                                  </div>

                                  <div className="flex gap-2">
                                    <button
                                      onClick={saveEdit}
                                      disabled={updateTask.isPending}
                                      className="flex-1 px-4 py-2 rounded-lg bg-green-600 text-white hover:bg-green-700 focus:ring-4 focus:ring-green-200 disabled:opacity-50 transition-all font-medium"
                                    >
                                      {updateTask.isPending
                                        ? "Saving..."
                                        : "Save"}
                                    </button>
                                    <button
                                      onClick={() => setEditTask(null)}
                                      className="flex-1 px-4 py-2 rounded-lg border border-gray-300 hover:bg-gray-50 transition-all font-medium"
                                    >
                                      Cancel
                                    </button>
                                  </div>
                                </>
                              ) : (
                                <>
                                  <div className="flex items-start gap-2 mb-2">
                                    <svg
                                      className="w-5 h-5 text-gray-400 flex-shrink-0 mt-0.5"
                                      fill="none"
                                      viewBox="0 0 24 24"
                                      stroke="currentColor"
                                    >
                                      <path
                                        strokeLinecap="round"
                                        strokeLinejoin="round"
                                        strokeWidth={2}
                                        d="M4 6h16M4 12h16M4 18h16"
                                      />
                                    </svg>
                                    <h3 className="font-semibold text-gray-900 flex-1">
                                      {task.title}
                                    </h3>
                                  </div>

                                  {task.description && (
                                    <p className="text-gray-600 text-sm mb-3 ml-7 whitespace-pre-wrap">
                                      {task.description}
                                    </p>
                                  )}

                                  {/* ✅ Show buttons on hover for cleaner UI */}
                                  <div className="flex gap-2 mt-3 opacity-0 group-hover:opacity-100 transition-opacity">
                                    <button
                                      onClick={() => setEditTask(task)}
                                      className="flex-1 px-3 py-1.5 text-sm bg-yellow-50 text-yellow-700 rounded-lg hover:bg-yellow-100 transition-all font-medium"
                                      aria-label={`Edit ${task.title}`}
                                    >
                                      Edit
                                    </button>

                                    <button
                                      onClick={() => setConfirmDelete(task)}
                                      className="flex-1 px-3 py-1.5 text-sm bg-red-50 text-red-700 rounded-lg hover:bg-red-100 transition-all font-medium"
                                      aria-label={`Delete ${task.title}`}
                                    >
                                      Delete
                                    </button>
                                  </div>
                                </>
                              )}
                            </div>
                          )}
                        </Draggable>
                      ))}

                      {/* ✅ Placeholder MUST be inside droppable */}
                      {provided.placeholder}

                      {/* Empty state */}
                      {board[column.id].length === 0 && (
                        <div className="text-center py-12 text-gray-400">
                          <p className="text-sm">Drop tasks here</p>
                        </div>
                      )}
                    </div>
                  )}
                </Droppable>
              </div>
            ))}
          </div>
        </DragDropContext>

        {/* Task Statistics */}
        {tasks.length > 0 && (
          <div className="mt-8 grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div className="text-center">
                <p className="text-3xl font-bold text-gray-900">
                  {board.TODO.length}
                </p>
                <p className="text-sm text-gray-600 mt-1">To Do</p>
              </div>
            </div>
            <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div className="text-center">
                <p className="text-3xl font-bold text-blue-600">
                  {board.IN_PROGRESS.length}
                </p>
                <p className="text-sm text-gray-600 mt-1">In Progress</p>
              </div>
            </div>
            <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
              <div className="text-center">
                <p className="text-3xl font-bold text-green-600">
                  {board.DONE.length}
                </p>
                <p className="text-sm text-gray-600 mt-1">Completed</p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Confirm Delete Modal */}
      {confirmDelete && (
        <ConfirmModal
          open={!!confirmDelete}
          title="Delete Task?"
          message="This action cannot be undone."
          onConfirm={confirmDeleteTask}
          onClose={() => setConfirmDelete(null)}
        />
      )}
    </div>
  );
}
