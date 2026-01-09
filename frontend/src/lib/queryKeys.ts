// src/lib/queryKeys.ts
export const teamMembersKey = (teamId: string) =>
  ["teams", teamId, "members"] as const;
