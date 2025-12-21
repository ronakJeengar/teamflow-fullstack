import { useContext } from "react";
import { ToastContext } from "./ToastContext";
import type { ToastContextValue } from "./toastTypes";

export const useToast = (): ToastContextValue => {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error("useToast must be used within a ToastProvider");
  return ctx;
};
