import { api } from './api';
import { API_ENDPOINTS } from '../constants';
import { LoginRequest, LoginResponse, User } from '../types';

export interface AuthService {
  login: (credentials: LoginRequest) => Promise<LoginResponse>;
  logout: () => Promise<void>;
  getCurrentUser: () => Promise<User>;
  refreshToken: () => Promise<string>;
  checkPermission: (requiredRole: string) => boolean;
}

class AuthServiceImpl implements AuthService {
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await api.post<LoginResponse>(API_ENDPOINTS.LOGIN, credentials);
    return response;
  }

  async logout(): Promise<void> {
    // 清除本地儲存的認證資訊
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  }

  async getCurrentUser(): Promise<User> {
    // 從本地儲存或 API 取得當前使用者資訊
    const userStr = localStorage.getItem('user');
    if (userStr) {
      return JSON.parse(userStr);
    }
    
    // 如果本地沒有，可以呼叫 API 取得
    // const response = await api.get<User>('/api/v1/auth/me');
    // return response;
    
    throw new Error('使用者資訊不存在');
  }

  async refreshToken(): Promise<string> {
    // 實作 Token 刷新邏輯
    const response = await api.post<{ token: string }>('/api/v1/auth/refresh');
    return response.token;
  }

  checkPermission(requiredRole: string): boolean {
    const userStr = localStorage.getItem('user');
    if (!userStr) return false;

    const user: User = JSON.parse(userStr);
    const roleHierarchy = {
      'Admin': 3,
      'Manager': 2,
      'Staff': 1,
    };

    const userLevel = roleHierarchy[user.role as keyof typeof roleHierarchy] || 0;
    const requiredLevel = roleHierarchy[requiredRole as keyof typeof roleHierarchy] || 0;

    return userLevel >= requiredLevel;
  }
}

export const authService = new AuthServiceImpl(); 