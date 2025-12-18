import { useState } from "react";
import { useTasks } from "../hooks/useTasks";
import CreateTaskModal from "../components/CreateTaskModel";

export default function Tasks({ projectId }: { projectId: string }) {
  const [open, setOpen] = useState(false);
  const { data: tasks, isLoading } = useTasks(projectId);

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

      {isLoading && <p>Loading...</p>}
      {!isLoading && tasks?.length === 0 && <p>No tasks yet</p>}

      <div className="space-y-2">
        {tasks?.map((task: any) => (
          <div key={task.id} className="border p-3 rounded">
            <p className="font-medium">{task.title}</p>
            <p className="text-sm text-gray-500">{task.status}</p>
          </div>
        ))}
      </div>

      {open && (
        <CreateTaskModal projectId={projectId} onClose={() => setOpen(false)} />
      )}
    </div>
  );
}
