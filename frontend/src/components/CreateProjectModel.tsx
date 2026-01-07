import { useState } from "react";
import { useCreateProject } from "../hooks/useCreateProject";

export default function CreateProjectModal({ teamId, onClose }: { teamId: string; onClose: () => void }) {
  const [name, setName] = useState("");
  const createProject = useCreateProject(teamId);

  const submit = async () => {
    if (!name) return alert("Project name required");
    await createProject.mutateAsync({ name });
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/30 flex items-center justify-center">
      <div className="bg-white p-6 rounded w-96">
        <h2 className="text-lg font-semibold mb-4">Create Project</h2>
        <input
          className="border p-2 w-full mb-4"
          placeholder="Project name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          />
          <div className="flex justify-end gap-2">
            <button onClick={onClose}>Cancel</button>
            <button
              className="bg-blue-600 text-white px-4 py-2 rounded"
              onClick={submit}
            >
              Create
            </button>
        </div>
      </div>
    </div>
  );
}
