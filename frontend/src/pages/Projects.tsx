import { useEffect, useState } from "react";
import { fetchProjects } from "../api/projects";
import type { Project } from "../types/Project";

export default function Projects() {
  const [projects, setProjects] = useState<Project[]>([]);

  useEffect(() => {
    const token = localStorage.getItem("token")!;
    fetchProjects(token).then(setProjects);
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-xl mb-4">Projects</h1>
      {projects.map((p: Project) => (
        <div key={p.id} className="border p-2 mb-2">
          {p.name}
        </div>
      ))}
    </div>
  );
}
