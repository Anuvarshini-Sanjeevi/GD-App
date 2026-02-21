import { Routes, Route, Navigate } from 'react-router-dom';
import { AdminLayout } from './layouts/AdminLayout';
import AdminDashboard from './pages/admin/Dashboard';
import SessionManager from './pages/admin/SessionManager';
import Analytics from './pages/admin/Analytics';
import StudentManager from './pages/admin/StudentManager';
import Settings from './pages/admin/Settings';
import Profile from './pages/admin/Profile';
import SessionDetailView from './pages/admin/SessionDetailView';
import { SessionDetail } from './components/admin/SessionDetail';
import Login from './pages/Login';
import SupervisorDashboard from './pages/supervisor/Dashboard';
import StudentDashboard from './pages/student/Dashboard';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Login />} />
      <Route path="/login" element={<Navigate to="/" replace />} />

      {/* Role-based Routes */}
      <Route path="/admin" element={<AdminLayout />}>
        <Route index element={<AdminDashboard />} />
        <Route path="sessions" element={<SessionManager />} />
        <Route path="students" element={<StudentManager />} />
        <Route path="session-detail/:id" element={<SessionDetailView />} />
        <Route path="analytics" element={<Analytics />} />
        <Route path="settings" element={<Settings />} />
        <Route path="profile" element={<Profile />} />
        <Route path="session/:id" element={<SessionDetail />} />
      </Route>

      <Route path="/supervisor" element={<SupervisorDashboard />} />
      <Route path="/student" element={<StudentDashboard />} />
    </Routes>
  );
}

export default App;
