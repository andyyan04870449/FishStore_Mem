import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface User {
  id: string;
  account: string;
  role: 'Admin' | 'Manager' | 'Staff';
  name?: string;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
}

// 從 localStorage 讀取用戶資訊
const getStoredUser = (): User | null => {
  try {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
  } catch (error) {
    console.error('解析用戶資訊失敗:', error);
    return null;
  }
};

const initialState: AuthState = {
  user: getStoredUser(),
  token: localStorage.getItem('token'),
  isAuthenticated: !!localStorage.getItem('token') && !!getStoredUser(),
  isLoading: false,
  error: null,
};

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    loginStart: (state) => {
      state.isLoading = true;
      state.error = null;
    },
    loginSuccess: (state, action: PayloadAction<{ user: User; token: string }>) => {
      state.isLoading = false;
      state.isAuthenticated = true;
      state.user = action.payload.user;
      state.token = action.payload.token;
      state.error = null;
      // 保存到 localStorage
      localStorage.setItem('token', action.payload.token);
      localStorage.setItem('user', JSON.stringify(action.payload.user));
    },
    loginFailure: (state, action: PayloadAction<string>) => {
      state.isLoading = false;
      state.error = action.payload;
    },
    logout: (state) => {
      state.user = null;
      state.token = null;
      state.isAuthenticated = false;
      state.error = null;
      // 清除 localStorage
      localStorage.removeItem('token');
      localStorage.removeItem('user');
    },
    clearError: (state) => {
      state.error = null;
    },
    initializeAuth: (state) => {
      // 從 localStorage 重新讀取認證資訊
      const token = localStorage.getItem('token');
      const user = getStoredUser();
      state.token = token;
      state.user = user;
      state.isAuthenticated = !!(token && user);
    },
  },
});

export const { loginStart, loginSuccess, loginFailure, logout, clearError, initializeAuth } =
  authSlice.actions;

export default authSlice.reducer; 