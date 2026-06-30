import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useToast } from "../context/useToast";
import type { Task, TaskPriority, TaskStatus } from "../types/Task";
import type { Sprint } from "../types/Sprint";
import type { TeamMember } from "../types/TeamMember";
import type { Comment } from "../types/Comment";

import { useAuth } from "../auth/AuthContext";

interface EditTaskModalProps {
  task: Task;
  projectId: string;
  teamId: string;
  onClose: () => void;
}

export default function EditTaskModal({ task, projectId, teamId, onClose }: EditTaskModalProps) {
  const { activeWorkspaceId } = useWorkspace();
  const { showToast } = useToast();
  const { user } = useAuth();
  const queryClient = useQueryClient();

  // Form Fields State
  const [title, setTitle] = useState(task.title);
  const [description, setDescription] = useState(task.description || "");
  const [status, setStatus] = useState<TaskStatus>(task.status);
  const [priority, setPriority] = useState<TaskPriority>(task.priority || "LOW");
  const [storyPoints, setStoryPoints] = useState<number>(task.storyPoints || 0);
  const [sprintId, setSprintId] = useState<string>(task.sprintId || "");
  const [assigneeId, setAssigneeId] = useState<string>(task.assignedToId || "");
  const [isBacklog, setIsBacklog] = useState<boolean>(task.isBacklog ?? false);

  // Comments Input State
  const [newComment, setNewComment] = useState("");
  const [commentLoading, setCommentLoading] = useState(false);

  // 1. Fetch team members for assignee list
  const { data: members = [] } = useQuery<TeamMember[]>({
    queryKey: ["team-members", teamId],
    queryFn: async () => {
      const res = await api.get(`/teams/${teamId}/members`);
      return res.data?.data ?? [];
    },
    enabled: !!teamId,
  });

  // 2. Fetch team sprints for sprint assignment
  const { data: sprints = [] } = useQuery<Sprint[]>({
    queryKey: ["team-sprints", teamId],
    queryFn: async () => {
      const res = await api.get("/sprints", {
        params: { teamId, workspaceId: activeWorkspaceId },
      });
      return res.data?.data ?? [];
    },
    enabled: !!teamId && !!activeWorkspaceId,
  });

  // 3. Fetch task comments
  const { data: comments = [], refetch: refetchComments } = useQuery<Comment[]>({
    queryKey: ["task-comments", task.id],
    queryFn: async () => {
      const res = await api.get(`/tasks/${task.id}/comments`);
      return res.data?.data ?? [];
    },
    enabled: !!task.id,
  });

  // Task Update Mutation
  const updateMutation = useMutation({
    mutationFn: async () => {
      await api.patch(`/tasks/${task.id}`, {
        title,
        description: description || null,
        status,
        priority,
        storyPoints: storyPoints || null,
        sprintId: sprintId || null,
        assignedToId: assigneeId || null,
        isBacklog,
      });
    },
    onSuccess: () => {
      showToast("Task updated successfully!", "success");
      queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
      queryClient.invalidateQueries({ queryKey: ["team-tasks", teamId] });
      onClose();
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to update task", "error");
    },
  });

  // Add Comment Mutation
  const addCommentMutation = useMutation({
    mutationFn: async () => {
      setCommentLoading(true);
      await api.post(`/tasks/${task.id}/comments`, { content: newComment });
    },
    onSuccess: () => {
      setNewComment("");
      refetchComments();
      // Invalidate tasks/timeline counts
      queryClient.invalidateQueries({ queryKey: ["tasks", projectId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to add comment", "error");
    },
    onSettled: () => {
      setCommentLoading(false);
    }
  });

  // Delete Comment Mutation
  const deleteCommentMutation = useMutation({
    mutationFn: async (commentId: string) => {
      await api.delete(`/comments/${commentId}`);
    },
    onSuccess: () => {
      showToast("Comment deleted", "success");
      refetchComments();
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to delete comment", "error");
    }
  });

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;
    updateMutation.mutate();
  };

  const handleAddComment = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newComment.trim()) return;
    addCommentMutation.mutate();
  };

  const priorityOptions = ["LOW", "MEDIUM", "HIGH", "URGENT"];
  const statusOptions = ["TODO", "IN_PROGRESS", "REVIEW", "BLOCKED", "DONE"];

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-4xl overflow-hidden animate-in fade-in zoom-in-95 duration-150 flex flex-col max-h-[90vh]">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2">
            <h3 className="font-bold text-gray-900 text-lg font-inter">Task Details</h3>
            <span className="text-[10px] font-mono bg-gray-100 text-gray-500 px-2 py-0.5 rounded-sm">
              ID: {task.id}
            </span>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 transition-colors">
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Splits Form */}
        <div className="flex-1 overflow-y-auto flex flex-col md:flex-row divide-y md:divide-y-0 md:divide-x divide-gray-100">
          
          {/* Left panel: Info & Comments */}
          <div className="flex-1 p-6 space-y-6 overflow-y-auto">
            
            {/* Title & Description Form inputs */}
            <div className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Title</label>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 font-bold"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Description</label>
                <textarea
                  placeholder="Task details and deliverables..."
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter focus:ring-2 focus:ring-indigo-500 h-28"
                />
              </div>
            </div>

            {/* Comments Section */}
            <div className="border-t border-gray-100 pt-6 space-y-4">
              <h4 className="font-bold text-gray-700 text-xs tracking-wider uppercase font-inter">Discussion Thread</h4>
              
              {/* Comment Input */}
              <form onSubmit={handleAddComment} className="flex gap-2">
                <input
                  type="text"
                  placeholder="Add a comment..."
                  value={newComment}
                  onChange={(e) => setNewComment(e.target.value)}
                  className="flex-1 px-3 py-1.5 border border-gray-300 rounded-lg text-xs font-inter focus:ring-2 focus:ring-indigo-500"
                />
                <button
                  type="submit"
                  disabled={commentLoading}
                  className="px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-400 text-white text-xs font-bold rounded-lg font-inter cursor-pointer transition-colors"
                >
                  Post
                </button>
              </form>

              {/* Feed List */}
              <div className="space-y-3">
                {comments.length === 0 ? (
                  <p className="text-[11px] text-gray-400 font-semibold font-inter py-2">No comments posted yet.</p>
                ) : (
                  comments.map((comm) => (
                    <div key={comm.id} className="p-3 bg-gray-50 border border-gray-100 rounded-lg flex items-start justify-between gap-3">
                      <div className="space-y-1">
                        <div className="flex items-center gap-2">
                          <span className="font-bold text-xs text-gray-800 font-inter">{comm.user.name}</span>
                          <span className="text-[9px] text-gray-400 font-inter">
                            {new Date(comm.createdAt).toLocaleDateString()}
                          </span>
                        </div>
                        <p className="text-xs text-gray-600 font-inter leading-relaxed">{comm.content}</p>
                      </div>
                      {comm.userId === user?.id && (
                        <button
                          onClick={() => deleteCommentMutation.mutate(comm.id)}
                          className="text-gray-400 hover:text-red-500 p-0.5"
                        >
                          <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                        </button>
                      )}
                    </div>
                  ))
                )}
              </div>

            </div>

          </div>

          {/* Right panel: Metadata controls */}
          <div className="w-full md:w-80 p-6 bg-gray-50/50 space-y-4 shrink-0 overflow-y-auto">
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Task Status</label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value as TaskStatus)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
              >
                {statusOptions.map((o) => (
                  <option key={o} value={o}>{o.replace("_", " ")}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Priority Tier</label>
              <select
                value={priority}
                onChange={(e) => setPriority(e.target.value as TaskPriority)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
              >
                {priorityOptions.map((o) => (
                  <option key={o} value={o}>{o}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Assignee</label>
              <select
                value={assigneeId}
                onChange={(e) => setAssigneeId(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
              >
                <option value="">Assign task</option>
                {members.map((m) => (
                  <option key={m.id} value={m.user?.id || ""}>{m.user?.name || "Unknown User"}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Story Points (SP)</label>
              <input
                type="number"
                min="0"
                value={storyPoints}
                onChange={(e) => setStoryPoints(parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white"
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Sprint Planning</label>
              <select
                value={sprintId}
                onChange={(e) => setSprintId(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm font-inter bg-white focus:outline-hidden"
              >
                <option value="">Backlog (No Sprint)</option>
                {sprints.map((s) => (
                  <option key={s.id} value={s.id}>{s.name} ({s.status})</option>
                ))}
              </select>
            </div>
            <div className="flex items-center gap-2 pt-2">
              <input
                id="isBacklogCheckbox"
                type="checkbox"
                checked={isBacklog}
                onChange={(e) => setIsBacklog(e.target.checked)}
                className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
              />
              <label htmlFor="isBacklogCheckbox" className="text-xs font-semibold text-gray-700 font-inter cursor-pointer">
                Place in Backlog
              </label>
            </div>
          </div>

        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-100 bg-gray-50 flex items-center justify-end gap-2 shrink-0">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 hover:bg-gray-50 text-sm font-medium rounded-lg font-inter cursor-pointer"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={updateMutation.isPending}
            className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-400 text-white text-sm font-semibold rounded-lg font-inter cursor-pointer transition-colors"
          >
            {updateMutation.isPending ? "Saving..." : "Save Changes"}
          </button>
        </div>

      </div>
    </div>
  );
}
