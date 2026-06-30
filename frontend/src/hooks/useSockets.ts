import { io } from 'socket.io-client';

const isLocal = typeof window !== "undefined" && (window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1");

export const socket = io(
  isLocal
    ? window.location.origin
    : (import.meta.env.VITE_API_URL || "http://localhost:3000"),
  {
    withCredentials: true,
  }
);
