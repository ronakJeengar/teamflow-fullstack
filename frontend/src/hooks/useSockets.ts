import { io } from 'socket.io-client';

export const socket = io(
  import.meta.env.DEV
    ? window.location.origin
    : (import.meta.env.VITE_API_URL || "http://localhost:3000"),
  {
    withCredentials: true,
  }
);
