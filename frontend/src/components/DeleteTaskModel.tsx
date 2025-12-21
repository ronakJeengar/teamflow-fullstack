import { useDeleteTask } from "../hooks/useDeleteTask";
import type { Task } from "../types/Task";

export default function DeleteTaskModal({
  task,
  projectId,
  onClose,
}: {
  task: Task;
  projectId: string;
  onClose: () => void;
}) {
  const deleteTask = useDeleteTask(projectId);

  const confirm = async () => {
    await deleteTask.mutateAsync(task.id);
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center">
      <div className="bg-white p-6 rounded w-96">
        <h2 className="text-lg font-semibold mb-4">Delete Task</h2>

        <p className="mb-4">
          Are you sure you want to delete
          <span className="font-semibold"> "{task.title}"</span>?
        </p>

        <div className="flex justify-end gap-2">
          <button onClick={onClose}>Cancel</button>

          <button
            className="bg-red-600 text-white px-4 py-2 rounded"
            onClick={confirm}
            disabled={deleteTask.isPending}
          >
            Delete
          </button>
        </div>
      </div>
    </div>
  );
}
