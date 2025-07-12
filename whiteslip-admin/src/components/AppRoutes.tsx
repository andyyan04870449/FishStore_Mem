import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { RootState } from '../store';
import LoginPage from '../pages/LoginPage';
import DashboardPage from '../pages/DashboardPage';
import MenuPage from '../pages/MenuPage';
import OrdersPage from '../pages/OrdersPage';
import Layout from './Layout/Layout';
import ReportsPage from '../pages/Reports/ReportsPage';
import UsersPage from '../pages/Users/UsersPage';
import SettingsPage from '../pages/Settings/SettingsPage';
import LogsPage from '../pages/Logs/LogsPage';
import { hasPermission } from '../utils/permission';

const AppRoutes: React.FC = () => {
  const { isAuthenticated, user } = useSelector((state: RootState) => state.auth);
  const role = user?.role;

  if (!isAuthenticated) {
    return (
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    );
  }

  return (
    <Layout>
      <Routes>
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/menu" element={<MenuPage />} />
        <Route path="/orders" element={<OrdersPage />} />
        {role && hasPermission(role, 'Manager') && <Route path="/reports" element={<ReportsPage />} />}
        {role === 'Admin' && <Route path="/users" element={<UsersPage />} />}
        {role === 'Admin' && <Route path="/settings" element={<SettingsPage />} />}
        {role === 'Admin' && <Route path="/logs" element={<LogsPage />} />}
        <Route path="/reports" element={<Navigate to="/dashboard" replace />} />
        <Route path="/users" element={<Navigate to="/dashboard" replace />} />
        <Route path="/settings" element={<Navigate to="/dashboard" replace />} />
        <Route path="/logs" element={<Navigate to="/dashboard" replace />} />
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </Layout>
  );
};

export default AppRoutes; 