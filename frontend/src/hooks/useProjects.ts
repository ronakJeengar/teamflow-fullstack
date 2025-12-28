import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";

export const useProjects = () =>
  useQuery({
    queryKey: ["projects"],
    queryFn: async () => {
      const res = await api.get("/projects");
      return res.data;
    },
  });
