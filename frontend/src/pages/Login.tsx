import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import type { AxiosError } from "axios";

export default function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await login(email, password);
      navigate("/teams", { replace: true });
    } catch (err) {
      const error = err as AxiosError<{ message: string }>;
      const errorMessage = error.response?.data?.message || "Login failed";
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="bg-white border border-gray-200 shadow-xl rounded-xl p-8 w-full max-w-md">
        <h1 className="text-2xl font-bold text-center mb-6 text-indigo-600">
          TeamFlow Login
        </h1>

        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="bg-red-950/20 border border-red-500/30 text-red-400 px-4 py-3 rounded-lg text-sm font-semibold font-inter">
              {error}
            </div>
          )}

          <input
            type="email"
            className="border border-gray-200 p-3 w-full rounded-lg focus:outline-none focus:ring-1 focus:ring-indigo-500 bg-white"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="Email"
            required
          />

          <input
            type="password"
            className="border border-gray-200 p-3 w-full rounded-lg focus:outline-none focus:ring-1 focus:ring-indigo-500 bg-white"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Password"
            required
          />

          <button
            type="submit"
            className="mt-6 w-full bg-indigo-600 text-white py-3 rounded-lg font-semibold hover:bg-indigo-700 transition-colors disabled:opacity-50 cursor-pointer"
            disabled={loading}
          >
            {loading ? "Logging in..." : "Login"}
          </button>
        </form>

        <p className="mt-4 text-center text-gray-500 text-sm">
          Don't have an account?{" "}
          <span
            className="text-indigo-600 font-medium cursor-pointer hover:underline"
            onClick={() => navigate("/register")}
          >
            Sign up
          </span>
        </p>
      </div>
    </div>
  );
}
