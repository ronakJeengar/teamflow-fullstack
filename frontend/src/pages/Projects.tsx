import { useState } from "react";
import { useProjects } from "../hooks/useProjects";
import type { Project } from "../types/Project";
import CreateProjectModal from "../components/CreateProjectModel";
import { useNavigate } from "react-router-dom";

export default function Projects() {
  const { data, isLoading } = useProjects();
  const [open, setOpen] = useState(false);
  const navigate = useNavigate();

  return (
    <div className="p-6">
      <div className="flex justify-between mb-4">
        <h1 className="text-xl font-semibold">Projects</h1>
        <button
          className="bg-blue-600 text-white px-4 py-2 rounded"
          onClick={() => setOpen(true)}
        >
          + Create Project
        </button>
      </div>

      {isLoading && <p>Loading...</p>}
      {!isLoading && data?.length === 0 && <p>No projects yet</p>}

      <div className="space-y-2">
        {data?.map((p: Project) => (
          <div
            key={p.id}
            className="border p-3 rounded cursor-pointer"
            // onClick={() => console.log("Navigate to project", p.id)}
            onClick={() => navigate(`/projects/${p.id}`)}
          >
            <p className="font-medium">{p.name}</p>
            {/* <p className="text-sm text-gray-500">
              {p._count?.tasks || 0} tasks
            </p> */}
          </div>
        ))}
      </div>

      {open && <CreateProjectModal onClose={() => setOpen(false)} />}
    </div>
  );
}
