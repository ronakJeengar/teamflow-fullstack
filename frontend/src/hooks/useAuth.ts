import { useContext } from "react";
import { AuthContext } from "../auth/AuthContext";
import type { AuthContextType } from "../auth/AuthProvider";

export const useAuth = (): AuthContextType => useContext(AuthContext);
