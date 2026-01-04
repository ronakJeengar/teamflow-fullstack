import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Projects from "./pages/Projects";
import Tasks from "./pages/Tasks";
import ProtectedRoute from "./auth/ProtectedRoute";
import Register from "./pages/Register";
import Teams from "./pages/Teams";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Public route */}
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />

        {/* Protected routes */}
        <Route
          path="/teams"
          element={
            <ProtectedRoute>
              <Teams />
            </ProtectedRoute>
          }
        />
        <Route
          path="/projects"
          element={
            <ProtectedRoute>
              <Projects />
            </ProtectedRoute>
          }
        />

        <Route
          path="/projects/:projectId"
          element={
            <ProtectedRoute>
              <Tasks />
            </ProtectedRoute>
          }
        />

        {/* Fallback */}
        <Route path="*" element={<Login />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
