import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { api } from "../api/client";
import { useWorkspace } from "../context/WorkspaceContext";
import { useToast } from "../context/useToast";
import type { WorkspaceMember } from "../types/Workspace";

interface WorkspaceMembersModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function WorkspaceMembersModal({ isOpen, onClose }: WorkspaceMembersModalProps) {
  const { activeWorkspaceId, activeWorkspace } = useWorkspace();
  const queryClient = useQueryClient();
  const { showToast } = useToast();
  
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("MEMBER");
  const [inviteLoading, setInviteLoading] = useState(false);

  // Fetch workspace members
  const { data: members = [], isLoading } = useQuery<WorkspaceMember[]>({
    queryKey: ["workspace-members", activeWorkspaceId],
    queryFn: async () => {
      if (!activeWorkspaceId) return [];
      const res = await api.get(`/workspaces/${activeWorkspaceId}/members`);
      return res.data.data;
    },
    enabled: isOpen && !!activeWorkspaceId,
  });

  // Mutation to add/invite member
  const inviteMutation = useMutation({
    mutationFn: async () => {
      setInviteLoading(true);
      await api.post(`/workspaces/${activeWorkspaceId}/members`, { email, role });
    },
    onSuccess: () => {
      showToast("Member added successfully!", "success");
      setEmail("");
      queryClient.invalidateQueries({ queryKey: ["workspace-members", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to add member", "error");
    },
    onSettled: () => {
      setInviteLoading(false);
    }
  });

  // Mutation to update role
  const updateRoleMutation = useMutation({
    mutationFn: async ({ memberId, newRole }: { memberId: string; newRole: string }) => {
      await api.patch(`/workspaces/${activeWorkspaceId}/members/${memberId}`, { role: newRole });
    },
    onSuccess: () => {
      showToast("Member role updated!", "success");
      queryClient.invalidateQueries({ queryKey: ["workspace-members", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to update role", "error");
    }
  });

  // Mutation to remove member
  const removeMutation = useMutation({
    mutationFn: async (memberId: string) => {
      await api.delete(`/workspaces/${activeWorkspaceId}/members/${memberId}`);
    },
    onSuccess: () => {
      showToast("Member removed successfully", "success");
      queryClient.invalidateQueries({ queryKey: ["workspace-members", activeWorkspaceId] });
    },
    onError: (err: any) => {
      showToast(err.response?.data?.message || "Failed to remove member", "error");
    }
  });

  if (!isOpen || !activeWorkspaceId) return null;

  const handleInvite = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;
    inviteMutation.mutate();
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-xs flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-xl border border-gray-200 w-full max-w-2xl overflow-hidden animate-in fade-in zoom-in-95 duration-150 flex flex-col max-h-[90vh]">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <h3 className="font-bold text-gray-900 text-lg font-inter">Manage Members</h3>
            <span className="text-xs bg-indigo-50 text-indigo-600 font-semibold px-2 py-0.5 rounded-full font-inter">
              {activeWorkspace?.name}
            </span>
          </div>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 transition-colors">
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Invite form */}
        <form onSubmit={handleInvite} className="p-6 border-b border-gray-100 bg-gray-50 flex items-end gap-3">
          <div className="flex-1">
            <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Email Address</label>
            <input
              type="email"
              required
              placeholder="collaborator@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-hidden focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm font-inter"
            />
          </div>
          <div className="w-32">
            <label className="block text-xs font-semibold text-gray-600 mb-1 font-inter">Role</label>
            <select
              value={role}
              onChange={(e) => setRole(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-hidden focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 text-sm font-inter bg-white"
            >
              <option value="OWNER">Owner</option>
              <option value="ADMIN">Admin</option>
              <option value="MEMBER">Member</option>
              <option value="VIEWER">Viewer</option>
            </select>
          </div>
          <button
            type="submit"
            disabled={inviteLoading}
            className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-400 rounded-lg h-9 font-inter flex items-center justify-center"
          >
            {inviteLoading ? "Adding..." : "Add Member"}
          </button>
        </form>

        {/* Members List */}
        <div className="flex-1 overflow-y-auto p-6 space-y-4">
          <h4 className="font-semibold text-gray-700 text-xs tracking-wider uppercase font-inter">Current Members</h4>
          {isLoading ? (
            <div className="py-8 text-center text-gray-500 font-inter text-sm">Loading members list...</div>
          ) : members.length === 0 ? (
            <div className="py-8 text-center text-gray-500 font-inter text-sm">No members inside this workspace yet.</div>
          ) : (
            <div className="divide-y divide-gray-100">
              {members.map((member) => (
                <div key={member.id} className="py-3 flex items-center justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-indigo-600 flex items-center justify-center text-white font-semibold font-inter">
                      {member.user.name.charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-gray-900 font-inter">{member.user.name}</p>
                      <p className="text-xs text-gray-500 font-inter">{member.user.email}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <select
                      value={member.role}
                      onChange={(e) => updateRoleMutation.mutate({ memberId: member.id, newRole: e.target.value })}
                      className="text-xs border border-gray-300 rounded-md px-2 py-1 font-inter bg-white focus:outline-hidden"
                    >
                      <option value="OWNER">Owner</option>
                      <option value="ADMIN">Admin</option>
                      <option value="MEMBER">Member</option>
                      <option value="VIEWER">Viewer</option>
                    </select>
                    <button
                      onClick={() => {
                        if (window.confirm(`Remove ${member.user.name} from this workspace?`)) {
                          removeMutation.mutate(member.id);
                        }
                      }}
                      className="text-gray-400 hover:text-red-600 transition-colors p-1"
                    >
                      <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-100 flex items-center justify-end bg-gray-50">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg font-inter hover:bg-gray-50"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
