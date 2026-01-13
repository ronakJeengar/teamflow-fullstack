import { useState, useEffect, type ReactNode, useRef } from "react";
import { AuthContext, type User } from "./AuthContext";
import { api } from "../api/client";
import { useLocation } from "react-router-dom";

interface AuthProviderProps {
  children: ReactNode;
}

const AUTH_ROUTES = ["/login", "/register"];

export const AuthProvider = ({ children }: AuthProviderProps) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const authChecked = useRef(false);
  const location = useLocation();
  const isAuthPage = AUTH_ROUTES.includes(location.pathname);

  // Check authentication status on mount
  useEffect(() => {
    if (isAuthPage) {
      setLoading(false);
      return;
    }

    if (authChecked.current) return;
    authChecked.current = true;
    const checkAuth = async () => {
      try {
        const response = await api.get("/auth/me");
        if (response.status === 204) {
          setUser(null); // silent, no console log
          return;
        }
        setUser(response.data);
      } catch (error) {
        console.log("Authentication check failed:", error);
        setUser(null);
      } finally {
        setLoading(false);
      }
    };

    checkAuth();
  }, [isAuthPage]);

  const login = async (email: string, password: string) => {
    const response = await api.post("/auth/login", { email, password });
    setUser(response.data.user);
  };

  const register = async (name: string, email: string, password: string) => {
    await api.post("/auth/register", { name, email, password });
    // Auto-login after registration
    await login(email, password);
  };

  const logout = async () => {
    try {
      await api.get("/auth/logout");
    } catch (error) {
      console.error("Logout error:", error);
    } finally {
      setUser(null);
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, register }}>
      {children}
    </AuthContext.Provider>
  );
};
