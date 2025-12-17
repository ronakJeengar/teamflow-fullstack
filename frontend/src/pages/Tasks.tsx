import { useParams } from "react-router-dom";
import { useTasks } from "../hooks/useTasks";

const columns = ["TODO", "IN_PROGRESS", "DONE"];

export default function Tasks() {
  const { projectId } = useParams();
  const { data: tasks = [], isLoading } = useTasks(projectId!);

  if (isLoading) return <div>Loading tasks...</div>;

  return (
    <div className="flex justify-between items-center mb-6">
      <h1 className="text-2xl font-semibold">Tasks</h1>

      <button className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
        + Add Task
      </button>
    </div>
  );
}
