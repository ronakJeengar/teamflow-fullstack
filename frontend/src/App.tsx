import { Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Projects from "./pages/Projects";
import Tasks from "./pages/Tasks";
import ProtectedRoute from "./auth/ProtectedRoute";
import Register from "./pages/Register";
import Teams from "./pages/Teams";
import TeamDetails from "./pages/TeamDetails";
import Dashboard from "./pages/Dashboard";
import Sprints from "./pages/Sprints";
import Settings from "./pages/Settings";
import Layout from "./components/Layout";

function App() {
  return (
    <Routes>
      {/* Public routes */}
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />

      {/* Protected Layout-wrapped routes */}
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <Layout>
              <Dashboard />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/settings"
        element={
          <ProtectedRoute>
            <Layout>
              <Settings />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teams"
        element={
          <ProtectedRoute>
            <Layout>
              <Teams />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teams/:teamId"
        element={
          <ProtectedRoute>
            <Layout>
              <TeamDetails />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teams/:teamId/sprints"
        element={
          <ProtectedRoute>
            <Layout>
              <Sprints />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/projects"
        element={
          <ProtectedRoute>
            <Layout>
              <Projects />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/projects/:projectId"
        element={
          <ProtectedRoute>
            <Layout>
              <Tasks />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Fallback */}
      <Route path="*" element={<Login />} />
    </Routes>
  );
}

export default App;
