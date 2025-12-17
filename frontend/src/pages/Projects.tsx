import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { fetchProjects } from "../api/projects";
import type { Project } from "../types/Project";

export default function Projects() {
  const [projects, setProjects] = useState<Project[]>([]);
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem("token")!;
    fetchProjects(token).then(setProjects);
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-xl mb-4">Projects</h1>
      {projects.map((p: Project) => (
        <div
          key={p.id}
          className="cursor-pointer border p-2 mb-2 hover:bg-gray-50"
          onClick={() => navigate(`/projects/${p.id}`)}
        >
          {p.name}
        </div>
      ))}
    </div>
  );
}
