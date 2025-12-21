import { useState } from "react";
import { useTasks } from "../hooks/useTasks";
import CreateTaskModal from "../components/CreateTaskModel";
import EditTaskModal from "../components/EditTaskModel";
import type { Task } from "../types/Task";
import { useParams } from "react-router-dom";

export default function Tasks() {
  const { projectId } = useParams<{ projectId: string }>(); // <- get param from URL
  const [open, setOpen] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);

  const { data: tasks, isPending } = useTasks(projectId || "");

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-xl font-semibold">Tasks</h1>
        <button
          className="bg-blue-600 text-white px-4 py-2 rounded"
          onClick={() => setOpen(true)}
        >
          + Create Task
        </button>
      </div>

      {isPending && <p>Loading...</p>}
      {!isPending && tasks?.length === 0 && <p>No tasks yet</p>}

      <div className="space-y-2">
        {tasks?.map((task: Task) => (
          <div
            key={task.id}
            className="border p-3 rounded cursor-pointer"
            onClick={() => setEditingTask(task)}
          >
            <p className="font-medium">{task.title}</p>
            <p className="text-sm text-gray-500">{task.status}</p>
          </div>
        ))}
      </div>

      {open && (
        <CreateTaskModal
          projectId={projectId!}
          onClose={() => setOpen(false)}
        />
      )}

      {editingTask && (
        <EditTaskModal
          task={editingTask}
          projectId={projectId!}
          onClose={() => setEditingTask(null)}
        />
      )}
    </div>
  );
}
