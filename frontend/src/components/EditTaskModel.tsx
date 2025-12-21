import { useState } from "react";
import { useUpdateTask } from "../hooks/useUpdateTask";
import type { Task } from "../types/Task";

export default function EditTaskModal({
  task,
  projectId,
  onClose,
}: {
  task: Task;
  projectId: string;
  onClose: () => void;
}) {
  const [title, setTitle] = useState(task.title);
  const [description, setDescription] = useState(task.description || "");
  const updateTask = useUpdateTask(projectId);

  const submit = async () => {
    await updateTask.mutateAsync({
      id: task.id,
      title,
      description,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center">
      <div className="bg-white p-6 rounded w-96">
        <h2 className="text-lg font-semibold mb-4">Edit Task</h2>

        <input
          className="border p-2 w-full mb-2"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />

        <textarea
          className="border p-2 w-full mb-4"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />

        <div className="flex justify-end gap-2">
          <button onClick={onClose}>Cancel</button>

          <button
            className="bg-blue-600 text-white px-4 py-2 rounded"
            onClick={submit}
            disabled={updateTask.isPending}
          >
            Save
          </button>
        </div>
      </div>
    </div>
  );
}
