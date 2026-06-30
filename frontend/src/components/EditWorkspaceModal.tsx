import { useState, useEffect } from "react";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useToast } from "../context/useToast";
import { useNavigate } from "react-router-dom";

interface EditWorkspaceModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function EditWorkspaceModal({ isOpen, onClose }: EditWorkspaceModalProps) {
  const { activeWorkspace, refetchWorkspaces, workspaces, switchWorkspace } = useWorkspace();
  const { showToast } = useToast();
  const navigate = useNavigate();
  const [name, setName] = useState("");
  const [color, setColor] = useState("#4f46e5");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (activeWorkspace) {
      setName(activeWorkspace.name);
      setColor(activeWorkspace.color);
    }
  }, [activeWorkspace, isOpen]);

  if (!isOpen || !activeWorkspace) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim()) return;

    setLoading(true);
    try {
      await api.patch(`/workspaces/${activeWorkspace.id}`, { name, color });
      showToast("Workspace updated successfully!", "success");
      refetchWorkspaces();
      onClose();
    } catch (err: any) {
      showToast(err.response?.data?.message || "Failed to update workspace", "error");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!window.confirm("Are you sure you want to delete this workspace? This action is permanent and will cascade delete all teams, projects, sprints, and tasks.")) {
      return;
    }

    setLoading(true);
    try {
      await api.delete(`/workspaces/${activeWorkspace.id}`);
      showToast("Workspace deleted successfully", "success");
      
      const remaining = workspaces.filter((w) => w.id !== activeWorkspace.id);
      if (remaining.length > 0) {
        await switchWorkspace(remaining[0].id);
      } else {
        localStorage.removeItem("active_workspace_id");
        window.location.reload();
      }
      refetchWorkspaces();
      onClose();
      navigate("/");
    } catch (err: any) {
      showToast(err.response?.data?.message || "Failed to delete workspace", "error");
    } finally {
      setLoading(false);
    }
  };

  const colors = ["#4f46e5", "#06b6d4", "#10b981", "#f59e0b", "#ef4444", "#ec4899", "#8b5cf6"];

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-md overflow-hidden animate-in fade-in zoom-in-95 duration-150">
        <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
          <h3 className="font-bold text-gray-900 text-lg font-inter">Workspace Settings</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 transition-colors">
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1 font-inter">Workspace Name</label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-hidden focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm font-inter"
            />
          </div>
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2 font-inter">Theme Color</label>
            <div className="flex items-center gap-2 flex-wrap">
              {colors.map((c) => (
                <button
                  key={c}
                  type="button"
                  onClick={() => setColor(c)}
                  style={{ backgroundColor: c }}
                  className={`w-8 h-8 rounded-full border-2 transition-all ${
                    color === c ? "border-gray-900 scale-110 shadow-sm" : "border-transparent hover:scale-105"
                  }`}
                />
              ))}
            </div>
          </div>
          <div className="border-t border-gray-100 pt-4 flex items-center justify-between gap-2">
            <button
              type="button"
              onClick={handleDelete}
              disabled={loading}
              className="px-3 py-2 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg transition-colors font-inter"
            >
              Delete Workspace
            </button>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 border border-gray-300 rounded-lg font-inter"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={loading}
                className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-400 rounded-lg flex items-center justify-center font-inter"
              >
                {loading ? "Saving..." : "Save Changes"}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
}
