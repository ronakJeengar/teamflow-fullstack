import axios, { AxiosError, type InternalAxiosRequestConfig } from "axios";
import { getOfflineQueue, saveOfflineQueue } from "./offlineManager.js";

export const api = axios.create({
  baseURL: "http://localhost:3000/api/v1",
  withCredentials: true,
});

// Request Interceptor to check online/offline and cache reads
api.interceptors.request.use(
  (config) => {
    const isMutation = ["post", "patch", "delete"].includes(config.method?.toLowerCase() || "");
    
    if (!navigator.onLine) {
      if (config.method?.toLowerCase() === "get") {
        const cached = localStorage.getItem(`cache_GET_${config.url}`);
        if (cached) {
          return Promise.resolve({
            data: JSON.parse(cached),
            status: 200,
            statusText: "OK",
            headers: {},
            config,
          } as any);
        }
        return Promise.reject(new AxiosError("No internet connection and no cache available"));
      } else if (isMutation) {
        const queue = getOfflineQueue();
        const queuedItem = {
          id: Math.random().toString(36).substring(2, 9),
          method: config.method || "POST",
          url: config.url || "",
          data: config.data,
          timestamp: new Date().toISOString(),
        };
        saveOfflineQueue([...queue, queuedItem]);

        return Promise.resolve({
          data: { success: true, message: "Offline operation queued", data: config.data },
          status: 200,
          statusText: "OK",
          headers: {},
          config,
        } as any);
      }
    }
    return config;
  },
  (error) => Promise.reject(error)
);

let isRefreshing = false;
let failedQueue: Array<{
  resolve: (value?: unknown) => void;
  reject: (reason?: unknown) => void;
}> = [];

const processQueue = (error: AxiosError | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve();
    }
  });
  failedQueue = [];
};

const authEndpoints = ["/auth/login", "/auth/register", "/auth/refresh"];

const isAuthEndpoint = (url?: string): boolean => {
  if (!url) return false;
  return authEndpoints.some((endpoint) => url.includes(endpoint));
};

api.interceptors.response.use(
  (response) => {
    if (response.config.method?.toLowerCase() === "get" && response.status === 200) {
      try {
        localStorage.setItem(`cache_GET_${response.config.url}`, JSON.stringify(response.data));
      } catch (e) {
        console.warn("Storage quota exceeded, unable to cache GET response");
      }
    }
    return response;
  },
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & {
      _retry?: boolean;
    };

    // Skip refresh logic for auth endpoints
    if (isAuthEndpoint(originalRequest.url)) {
      return Promise.reject(error);
    }

    // Skip /auth/me 204 responses (no session)
    if (
      (error.response?.status === 204 || error.response?.status === 401) &&
      originalRequest.url?.includes("/auth/me")
    ) {
      return Promise.resolve(error.response); // Treat as “not logged in”, no retry
    }

    // If error is 401 and we haven't retried yet
    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        // If already refreshing, queue this request
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then(() => api(originalRequest))
          .catch((err) => Promise.reject(err));
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        // Call your refresh token endpoint
        const refreshResponse = await api.post("/auth/refresh");

        if (refreshResponse.status === 204) {
          processQueue(new AxiosError("No session"));
          return Promise.reject(new AxiosError("No session"));
        }
        // Token refreshed successfully, process queued requests
        processQueue(null);

        // Retry the original request
        return api(originalRequest);
      } catch (refreshError) {
        // Refresh failed, reject all queued requests
        processQueue(refreshError as AxiosError);

        // Optional: redirect to login or dispatch logout action
        // window.location.href = '/login';

        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);
