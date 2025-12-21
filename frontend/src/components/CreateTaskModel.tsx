import { useState } from 'react';
import { useCreateTask } from '../hooks/useCreateTask';

export default function CreateTaskModal({
  projectId,
  onClose,
}: {
  projectId: string;
  onClose: () => void;
}) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const createTask = useCreateTask();

  const submit = async () => {
    await createTask.mutateAsync({
      title,
      description,
      projectId,
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center">
      <div className="bg-white p-6 rounded w-96">
        <h2 className="text-lg font-semibold mb-4">Create Task</h2>

        <input
          className="border p-2 w-full mb-2"
          placeholder="Title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />

        <textarea
          className="border p-2 w-full mb-4"
          placeholder="Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />

        <div className="flex justify-end gap-2">
          <button onClick={onClose}>Cancel</button>
          <button
            className="bg-blue-600 text-white px-4 py-2 rounded"
            onClick={submit}
            disabled={createTask.isPending}
          >
            Create
          </button>
        </div>
      </div>
    </div>
  );
}
