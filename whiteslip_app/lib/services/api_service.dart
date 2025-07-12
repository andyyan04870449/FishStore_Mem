import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/menu.dart';
import '../models/auth.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5000/api/v1';
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加 JWT token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // 處理 401 錯誤，清除過期 token
        if (error.response?.statusCode == 401) {
          _clearToken();
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // 認證相關
  Future<AuthResponse> authenticate(String deviceCode) async {
    try {
      final response = await _dio.post('/auth', data: {
        'deviceCode': deviceCode,
      });
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      // 儲存 JWT token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', authResponse.jwt);
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 菜單相關
  Future<Menu> getMenu({int? version}) async {
    try {
      final queryParams = version != null ? {'version': version} : null;
      final response = await _dio.get('/menu', queryParameters: queryParams);
      return Menu.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 訂單同步
  Future<void> syncOrders(List<Order> orders) async {
    try {
      final ordersJson = orders.map((order) => order.toJson()).toList();
      await _dio.post('/orders/bulk', data: ordersJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 重新列印訂單
  Future<void> reprintOrder(String orderId) async {
    try {
      await _dio.post('/orders/$orderId/reprint');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 取得報表
  Future<String> getReport(DateTime from, DateTime to) async {
    try {
      final response = await _dio.get('/reports', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 檢查網路連線
  Future<bool> checkConnection() async {
    try {
      await _dio.get('/healthz');
      return true;
    } catch (e) {
      return false;
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('連線超時，請檢查網路連線');
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
            return Exception('請求格式錯誤');
          case 401:
            return Exception('認證失敗，請重新登入');
          case 403:
            return Exception('權限不足');
          case 404:
            return Exception('資源不存在');
          case 500:
            return Exception('伺服器內部錯誤');
          default:
            return Exception('網路錯誤: ${e.response?.statusCode}');
        }
      case DioExceptionType.cancel:
        return Exception('請求已取消');
      default:
        return Exception('網路連線錯誤');
    }
  }
}

// API 錯誤類別
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
} 