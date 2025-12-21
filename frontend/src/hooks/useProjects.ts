import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";

export const useProjects = () =>
  useQuery({
    queryKey: ["projects"],
    queryFn: async () => {
      const token = localStorage.getItem("token")!;
      const res = await api.get("/projects", {
        headers: { Authorization: `Bearer ${token}` },
      });
      return res.data;
    },
  });
