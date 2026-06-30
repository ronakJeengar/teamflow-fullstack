import { api } from "./client";

export type SyncStatus = "synced" | "pending" | "offline" | "syncing";

export interface QueuedMutation {
  id: string;
  method: string;
  url: string;
  data: any;
  timestamp: string;
}

let isSyncing = false;

export const getOfflineQueue = (): QueuedMutation[] => {
  try {
    const queue = localStorage.getItem("offline_mutations_queue");
    return queue ? JSON.parse(queue) : [];
  } catch {
    return [];
  }
};

export const saveOfflineQueue = (queue: QueuedMutation[]) => {
  localStorage.setItem("offline_mutations_queue", JSON.stringify(queue));
  window.dispatchEvent(new Event("sync-queue-updated"));
  window.dispatchEvent(new Event("sync-status-changed"));
};

export const getSyncStatus = (): SyncStatus => {
  if (!navigator.onLine) return "offline";
  const queue = getOfflineQueue();
  if (queue.length > 0) return isSyncing ? "syncing" : "pending";
  return "synced";
};

export const clearOfflineQueue = () => {
  saveOfflineQueue([]);
};

export const syncOfflineMutations = async () => {
  if (isSyncing || !navigator.onLine) return;
  const queue = getOfflineQueue();
  if (queue.length === 0) return;

  isSyncing = true;
  window.dispatchEvent(new Event("sync-status-changed"));

  const remaining = [...queue];

  for (let i = 0; i < queue.length; i++) {
    const item = queue[i];
    try {
      if (item.method.toLowerCase() === "post") {
        await api.post(item.url, item.data);
      } else if (item.method.toLowerCase() === "patch") {
        await api.patch(item.url, item.data);
      } else if (item.method.toLowerCase() === "delete") {
        await api.delete(item.url);
      }
      remaining.shift();
      saveOfflineQueue(remaining);
    } catch (error: any) {
      console.error("[Offline Sync Error] Failed to process mutation:", item.url, error);
      // Drop 4xx client errors, retry on 5xx server errors
      if (error.response && error.response.status >= 400 && error.response.status < 500) {
        remaining.shift();
        saveOfflineQueue(remaining);
      } else {
        break;
      }
    }
  }

  isSyncing = false;
  window.dispatchEvent(new Event("sync-status-changed"));
};

if (typeof window !== "undefined") {
  window.addEventListener("online", () => {
    syncOfflineMutations();
  });
  window.addEventListener("offline", () => {
    window.dispatchEvent(new Event("sync-status-changed"));
  });
}
