// API 基礎 URL
export const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5001';

// API 端點
export const API_ENDPOINTS = {
  LOGIN: '/api/v1/auth/user-login',
  MENU: '/api/v1/menu',
  MENU_LATEST_VERSION: '/api/v1/menu/latest-version',
  ORDERS: '/api/v1/orders',
  REPORTS: '/api/v1/reports',
  USERS: '/api/v1/users',
  HEALTH: '/healthz',
} as const;

// 角色權限
export const ROLES = {
  ADMIN: 'Admin',
  MANAGER: 'Manager',
  STAFF: 'Staff',
} as const;

// 路由路徑
export const ROUTES = {
  LOGIN: '/login',
  DASHBOARD: '/dashboard',
  MENU: '/menu',
  ORDERS: '/orders',
  REPORTS: '/reports',
  USERS: '/users',
  SETTINGS: '/settings',
} as const;

// 本地儲存鍵值
export const STORAGE_KEYS = {
  TOKEN: 'token',
  USER: 'user',
  THEME: 'theme',
} as const;

// 分頁設定
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100],
} as const;

// 日期格式
export const DATE_FORMATS = {
  DISPLAY: 'YYYY-MM-DD',
  DATETIME: 'YYYY-MM-DD HH:mm:ss',
  TIME: 'HH:mm:ss',
} as const;

// 主題設定
export const THEMES = {
  LIGHT: 'light',
  DARK: 'dark',
} as const; 