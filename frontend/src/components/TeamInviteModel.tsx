import { useState } from "react";
import { useInviteMember } from "../hooks/useInviteMember";

type Props = {
  teamId: string;
  onClose: () => void;
};

export default function InviteMemberModal({ teamId, onClose }: Props) {
  const [email, setEmail] = useState("");
  const [role, setRole] = useState("MEMBER");
  const inviteMutation = useInviteMember(teamId);

  const submit = async () => {
    if (!email.trim()) return;
    await inviteMutation.mutateAsync({ email, role });
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl p-6 w-full max-w-md">
        <h2 className="text-xl font-semibold mb-4">Invite Member</h2>

        <input
          type="email"
          placeholder="Email address"
          className="w-full border rounded p-2 mb-3"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />

        <select
          className="w-full border rounded p-2 mb-4"
          value={role}
          onChange={(e) => setRole(e.target.value)}
        >
          <option value="ADMIN">Admin</option>
          <option value="MEMBER">Member</option>
          <option value="VIEWER">Viewer</option>
        </select>

        <div className="flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 border rounded">
            Cancel
          </button>
          <button
            onClick={submit}
            disabled={inviteMutation.isPending}
            className="px-4 py-2 bg-blue-600 text-white rounded"
          >
            {inviteMutation.isPending ? "Sending..." : "Send Invite"}
          </button>
        </div>
      </div>
    </div>
  );
}
