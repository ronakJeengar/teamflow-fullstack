import { useState, useEffect } from "react";
import type { ReactNode } from "react";

import { AuthContext } from "./AuthContext";

// Type for context
export interface AuthContextType {
  token: string | null;
  setToken: (token: string | null) => void;
}

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [token, setToken] = useState<string | null>(
    localStorage.getItem("token")
  );

  useEffect(() => {
    if (token) localStorage.setItem("token", token);
    else localStorage.removeItem("token");
  }, [token]);

  return (
    <AuthContext.Provider value={{ token, setToken }}>
      {children}
    </AuthContext.Provider>
  );
};
