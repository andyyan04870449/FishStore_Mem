import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/menu.dart';
import '../models/auth.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/print_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storageService = StorageServiceFactory.create();
  final ApiService _apiService = ApiService();

  // 認證狀態
  Device? _device;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isTokenValidating = false;

  // 菜單狀態
  Menu? _menu;
  bool _isMenuLoading = false;

  // 訂單狀態
  List<OrderItem> _currentOrderItems = [];
  bool _isPrinting = false;

  // 網路狀態
  bool _isOnline = true;

  // Getters
  Device? get device => _device;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isTokenValidating => _isTokenValidating;
  Menu? get menu => _menu;
  bool get isMenuLoading => _isMenuLoading;
  List<OrderItem> get currentOrderItems => _currentOrderItems;
  bool get isPrinting => _isPrinting;
  bool get isOnline => _isOnline;

  // 計算總計
  double get currentOrderTotal {
    return _currentOrderItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  // 初始化應用程式
  Future<void> initialize() async {
    // 直接設置狀態，不觸發 notifyListeners
    _isLoading = true;
    
    try {
      // 設置權杖過期回調
      _apiService.setTokenExpiredCallback(() async {
        debugPrint('權杖過期，清除認證狀態');
        await _clearAuthentication();
      });
      
      // 檢查網路連線
      await _checkConnectivity();
      
      // 載入本地裝置資訊並驗證權杖
      await _loadAndValidateDevice();
      
      // 載入本地菜單
      await _loadLocalMenu();
      
      // 同步未同步的訂單
      await _syncUnsyncedOrders();
      
      // 檢查菜單更新
      await _checkMenuUpdate();
      
    } catch (e) {
      debugPrint('初始化失敗: $e');
    } finally {
      _isLoading = false;
    }
  }

  // 認證
  Future<bool> authenticate(String deviceCode) async {
    _setLoading(true);
    
    try {
      final authResponse = await _apiService.authenticate(deviceCode);
      
      _device = Device(
        deviceId: authResponse.token, // 使用 token 作為 deviceId
        jwt: authResponse.token,
        lastSeen: DateTime.now(),
      );
      
      await _storageService.saveDevice(_device!);
      _isAuthenticated = true;
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('認證失敗: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 載入裝置資訊並驗證權杖
  Future<void> _loadAndValidateDevice() async {
    _device = await _storageService.getDevice();
    
    if (_device != null && _device!.jwt.isNotEmpty) {
      // 有權杖，驗證是否有效
      await _validateToken();
    } else {
      _isAuthenticated = false;
    }
  }

  // 驗證權杖有效性
  Future<void> _validateToken() async {
    if (_isTokenValidating) return;
    
    _isTokenValidating = true;
    notifyListeners();
    
    try {
      // 使用新的權杖驗證方法
      final isValid = await _apiService.isTokenValid();
      
      if (isValid) {
        _isAuthenticated = true;
        debugPrint('權杖驗證成功');
      } else {
        await _clearAuthentication();
      }
      
    } catch (e) {
      // 權杖無效，清除本地資料
      debugPrint('權杖驗證失敗: $e');
      await _clearAuthentication();
    } finally {
      _isTokenValidating = false;
      notifyListeners();
    }
  }

  // 清除認證資料
  Future<void> _clearAuthentication() async {
    _device = null;
    _isAuthenticated = false;
    
    // 清除 SharedPreferences 中的權杖
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    
    // 清除本地裝置資訊
    await _storageService.clearDevice();
    
    debugPrint('認證資料已清除');
  }

  // 載入本地菜單
  Future<void> _loadLocalMenu() async {
    _menu = await _storageService.getMenu();
  }

  // 檢查菜單更新
  Future<void> _checkMenuUpdate() async {
    if (!_isAuthenticated || !_isOnline) return;
    
    try {
      final currentVersion = _menu?.version ?? 0;
      final newMenu = await _apiService.getMenu(version: currentVersion);
      
      if (newMenu.version > currentVersion) {
        await _storageService.saveMenu(newMenu);
        _menu = newMenu;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('檢查菜單更新失敗: $e');
      // 如果是認證錯誤，清除認證狀態
      if (e.toString().contains('認證失敗') || e.toString().contains('401')) {
        await _clearAuthentication();
      }
    }
  }

  // 同步未同步的訂單
  Future<void> _syncUnsyncedOrders() async {
    if (!_isAuthenticated || !_isOnline) return;
    
    try {
      final unsyncedOrders = await _storageService.getUnsyncedOrders();
      
      if (unsyncedOrders.isNotEmpty) {
        // 分批同步，每批 20 筆
        const batchSize = 20;
        for (int i = 0; i < unsyncedOrders.length; i += batchSize) {
          final batch = unsyncedOrders.skip(i).take(batchSize).toList();
          await _apiService.syncOrders(batch);
          
          // 標記為已同步
          for (final order in batch) {
            await _storageService.markOrderAsSynced(order.orderId);
          }
        }
      }
    } catch (e) {
      debugPrint('同步訂單失敗: $e');
      // 如果是認證錯誤，清除認證狀態
      if (e.toString().contains('認證失敗') || e.toString().contains('401')) {
        await _clearAuthentication();
      }
    }
  }

  // 檢查網路連線
  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = connectivityResult != ConnectivityResult.none;
    
    // 監聽網路狀態變化
    Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      
      // 網路恢復時同步訂單
      if (_isOnline) {
        _syncUnsyncedOrders();
      }
    });
  }

  // 新增商品到訂單
  void addItemToOrder(MenuItem menuItem) {
    final existingIndex = _currentOrderItems.indexWhere((item) => item.sku == menuItem.sku);
    
    if (existingIndex >= 0) {
      // 增加數量
      final existingItem = _currentOrderItems[existingIndex];
      _currentOrderItems[existingIndex] = existingItem.copyWith(
        qty: existingItem.qty + 1,
        subtotal: (existingItem.qty + 1) * existingItem.unitPrice,
      );
    } else {
      // 新增項目
      _currentOrderItems.add(OrderItem(
        sku: menuItem.sku,
        name: menuItem.name,
        qty: 1,
        unitPrice: menuItem.price,
        subtotal: menuItem.price,
      ));
    }
    
    notifyListeners();
  }

  // 減少商品數量
  void decreaseItemQuantity(String sku) {
    final index = _currentOrderItems.indexWhere((item) => item.sku == sku);
    if (index >= 0) {
      final item = _currentOrderItems[index];
      if (item.qty > 1) {
        _currentOrderItems[index] = item.copyWith(
          qty: item.qty - 1,
          subtotal: (item.qty - 1) * item.unitPrice,
        );
      } else {
        // 數量為 0 時移除
        _currentOrderItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  // 移除商品
  void removeItemFromOrder(String sku) {
    _currentOrderItems.removeWhere((item) => item.sku == sku);
    notifyListeners();
  }

  // 清空訂單
  void clearOrder() {
    _currentOrderItems.clear();
    notifyListeners();
  }

  // 列印訂單
  Future<bool> printOrder() async {
    if (_currentOrderItems.isEmpty) return false;
    
    _setPrinting(true);
    
    try {
      // 建立訂單
      final order = Order(
        orderId: PrintService.generateOrderId(),
        createdAt: DateTime.now(),
        synced: false,
        items: _currentOrderItems,
        discounts: [], // 暫時沒有折扣
        total: currentOrderTotal,
        businessDay: PrintService.generateBusinessDay(),
      );
      
      // 儲存到本地資料庫
      await _storageService.insertOrder(order);
      
      // 列印
      final success = await PrintService.simulatePrint(order);
      
      if (success) {
        // 清空當前訂單
        clearOrder();
        
        // 嘗試同步到後端
        if (_isOnline) {
          await _syncUnsyncedOrders();
        }
      }
      
      return success;
    } catch (e) {
      debugPrint('列印失敗: $e');
      return false;
    } finally {
      _setPrinting(false);
    }
  }

  // 重新列印訂單
  Future<bool> reprintOrder(String orderId) async {
    if (!_isAuthenticated) return false;
    
    try {
      await _apiService.reprintOrder(orderId);
      return true;
    } catch (e) {
      debugPrint('重新列印失敗: $e');
      return false;
    }
  }

  // 手動更新菜單
  Future<bool> updateMenu() async {
    if (!_isAuthenticated) return false;
    
    _setMenuLoading(true);
    
    try {
      final newMenu = await _apiService.getMenu();
      await _storageService.saveMenu(newMenu);
      _menu = newMenu;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新菜單失敗: $e');
      return false;
    } finally {
      _setMenuLoading(false);
    }
  }

  // 登出
  Future<void> logout() async {
    await _clearAuthentication();
    _menu = null;
    _currentOrderItems.clear();
    notifyListeners();
  }

  // 私有方法
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setMenuLoading(bool loading) {
    _isMenuLoading = loading;
    notifyListeners();
  }

  void _setPrinting(bool printing) {
    _isPrinting = printing;
    notifyListeners();
  }

  @override
  void dispose() {
    _storageService.close();
    super.dispose();
  }
} 