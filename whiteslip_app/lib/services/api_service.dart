import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/menu.dart';
import '../models/auth.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:5001/api/v1';
  late final Dio _dio;
  
  // 權杖過期回調
  VoidCallback? _onTokenExpired;
  
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
      onError: (error, handler) async {
        // 處理 401 錯誤，清除過期 token
        if (error.response?.statusCode == 401) {
          await _clearToken();
          // 通知權杖過期
          _onTokenExpired?.call();
        }
        handler.next(error);
      },
    ));
  }

  // 設置權杖過期回調
  void setTokenExpiredCallback(VoidCallback callback) {
    _onTokenExpired = callback;
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
      await prefs.setString('jwt_token', authResponse.token);
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // 檢查權杖是否有效
  Future<bool> isTokenValid() async {
    try {
      // 嘗試呼叫一個需要認證的 API
      await _dio.get('/menu', queryParameters: {'version': 0});
      return true;
    } catch (e) {
      return false;
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
      print('=== 開始同步訂單，數量: ${orders.length} ===');
      
      // 轉換為後端期望的格式
      final ordersJson = orders.map((order) {
        final businessDay = DateTime.parse(order.businessDay);
        return {
          'orderId': order.orderId,
          'businessDay': businessDay.toIso8601String(),
          'total': order.total,
          'createdAt': order.createdAt.toIso8601String(),
          'items': order.items.map((item) => {
            'name': item.name,
            'qty': item.qty,
            'unitPrice': item.unitPrice,
            'subtotal': item.subtotal,
          }).toList(),
        };
      }).toList();

      print('=== 同步訂單 payload ===');
      print(ordersJson.toString());
      print('=== payload 結束 ===');

      await _dio.post('/orders/bulk', data: ordersJson);
      print('=== 同步訂單成功 ===');
    } on DioException catch (e) {
      print('=== 同步訂單失敗: ${e.message} ===');
      print('=== 錯誤詳情: ${e.response?.data} ===');
      throw _handleDioError(e);
    } catch (e) {
      print('=== 同步訂單其他錯誤: $e ===');
      rethrow;
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