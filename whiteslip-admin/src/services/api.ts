import { API_BASE_URL } from '../constants';

// API 請求配置
const API_CONFIG = {
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
};

// 請求攔截器
const addAuthHeader = (config: RequestInit): RequestInit => {
  const token = localStorage.getItem('token');
  if (token) {
    return {
      ...config,
      headers: {
        ...config.headers,
        Authorization: `Bearer ${token}`,
      },
    };
  }
  return config;
};

// 回應攔截器
const handleResponse = async (response: Response) => {
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
  }
  const data = await response.json();
  return data;
};

// 通用 API 請求函數
export const apiRequest = async <T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> => {
  try {
    const config = addAuthHeader({
      ...API_CONFIG,
      ...options,
    });

    const response = await fetch(`${API_CONFIG.baseURL}${endpoint}`, config);
    return await handleResponse(response);
  } catch (error) {
    console.error('API Request Error:', error);
    // message.error(error instanceof Error ? error.message : '網路錯誤，請稍後再試'); // 移除全域錯誤彈窗
    throw error;
  }
};

// API 方法
export const api = {
  // GET 請求
  get: <T>(endpoint: string, options?: RequestInit): Promise<T> =>
    apiRequest<T>(endpoint, { method: 'GET', ...options }),

  // POST 請求
  post: <T>(endpoint: string, data?: any): Promise<T> =>
    apiRequest<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    }),

  // PUT 請求
  put: <T>(endpoint: string, data?: any): Promise<T> =>
    apiRequest<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    }),

  // DELETE 請求
  delete: <T>(endpoint: string): Promise<T> =>
    apiRequest<T>(endpoint, { method: 'DELETE' }),
}; 