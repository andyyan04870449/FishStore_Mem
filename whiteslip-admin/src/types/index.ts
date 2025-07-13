// API 回應類型
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

// 登入請求類型
export interface LoginRequest {
  account: string;
  password: string;
}

// 登入回應類型
export interface LoginResponse {
  success: boolean;
  token: string;
  role: string;
  expiresAt: string;
  message: string;
}

// 授權碼相關類型
export interface GenerateAuthCodeRequest {
  deviceName: string;
}

export interface AuthCodeResponse {
  success: boolean;
  authCode?: string;
  deviceId?: string;
  message: string;
}

export enum DeviceStatus {
  Inactive = 0,
  Active = 1,
  Disabled = 2,
  Deleted = 3
}

export interface DeviceInfo {
  deviceId: string;
  deviceCode: string;
  deviceName?: string;
  lastSeen: string;
  status: DeviceStatus;
  createdAt: string;
  activatedAt?: string;
  disabledAt?: string;
  deletedAt?: string;
  isActive: boolean;
}

export interface DeviceListResponse {
  success: boolean;
  devices: DeviceInfo[];
  totalCount: number;
  message?: string;
}

export interface BaseResponse {
  success: boolean;
  message: string;
}

// 菜單類型
export interface MenuItem {
  name: string;
  price: number;
}

export interface MenuCategory {
  name: string;
  items: MenuItem[];
}

export interface Menu {
  id: string;
  version: number;
  lastUpdated: string;
  menu: {
    categories: MenuCategory[];
  };
}

// 訂單類型
export interface OrderItem {
  name: string;
  qty: number;
  unitPrice: number;
  subtotal: number;
}

export interface Order {
  id: string;
  orderId: string;
  businessDay: string;
  total: number;
  createdAt: string;
  items: OrderItem[];
}

// 使用者類型
export interface User {
  id: string;
  account: string;
  role: 'Admin' | 'Manager' | 'Staff';
  name?: string;
  createdAt?: string;
  lastLoginAt?: string;
}

// 報表類型
export interface ReportData {
  date: string;
  revenue: number;
  orders: number;
  averageOrderValue: number;
}

// 路由類型
export interface RouteConfig {
  path: string;
  element: React.ComponentType;
  requiresAuth?: boolean;
  requiredRole?: string[];
} 