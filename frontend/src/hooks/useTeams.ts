import { useQuery } from "@tanstack/react-query";
import { api } from "../api/client";

export const useTeams = () =>
  useQuery({
    queryKey: ["teams"],
    queryFn: async () => {
      const res = await api.get("/teams");
      return res.data;
    },
  });
