import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/menu.dart';
import '../models/auth.dart';

abstract class StorageService {
  Future<void> saveDevice(Device device);
  Future<Device?> getDevice();
  Future<void> clearDevice();
  Future<void> saveMenu(Menu menu);
  Future<Menu?> getMenu();
  Future<void> insertOrder(Order order);
  Future<List<Order>> getUnsyncedOrders();
  Future<void> markOrderAsSynced(String orderId);
  Future<void> close();
}

class WebStorageService implements StorageService {
  static const String _deviceKey = 'device';
  static const String _menuKey = 'menu';
  static const String _ordersKey = 'orders';

  @override
  Future<void> saveDevice(Device device) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceData = {
      'deviceId': device.deviceId,
      'jwt': device.jwt,
      'lastSeen': device.lastSeen.toIso8601String(),
    };
    await prefs.setString(_deviceKey, jsonEncode(deviceData));
  }

  @override
  Future<Device?> getDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceString = prefs.getString(_deviceKey);
    if (deviceString == null) return null;
    
    try {
      final data = jsonDecode(deviceString) as Map<String, dynamic>;
      return Device(
        deviceId: data['deviceId'] ?? '',
        jwt: data['jwt'] ?? '',
        lastSeen: DateTime.parse(data['lastSeen'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceKey);
  }

  @override
  Future<void> saveMenu(Menu menu) async {
    final prefs = await SharedPreferences.getInstance();
    final menuData = {
      'version': menu.version,
      'updatedAt': menu.updatedAt.toIso8601String(),
      'menu': {
        'categories': menu.menu.categories.map((category) => {
          'name': category.name,
          'items': category.items.map((item) => {
            'sku': item.sku,
            'name': item.name,
            'price': item.price,
            'available': item.available,
          }).toList(),
        }).toList(),
      },
    };
    await prefs.setString(_menuKey, jsonEncode(menuData));
  }

  @override
  Future<Menu?> getMenu() async {
    final prefs = await SharedPreferences.getInstance();
    final menuString = prefs.getString(_menuKey);
    if (menuString == null) return null;
    
    try {
      final data = jsonDecode(menuString) as Map<String, dynamic>;
      final categories = (data['menu']?['categories'] as List?)?.map((category) => MenuCategory(
        name: category['name'] ?? '',
        items: (category['items'] as List?)?.map((item) => MenuItem(
          sku: item['sku'] ?? '',
          name: item['name'] ?? '',
          price: (item['price'] ?? 0.0).toDouble(),
          available: item['available'] ?? true,
        )).toList() ?? [],
      )).toList() ?? [];
      
      return Menu(
        version: data['version'] ?? 0,
        updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
        menu: MenuData(categories: categories),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> insertOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final orders = await getUnsyncedOrders();
    orders.add(order);
    
    final ordersData = orders.map((o) => {
      'orderId': o.orderId,
      'createdAt': o.createdAt.toIso8601String(),
      'synced': o.synced,
      'total': o.total,
      'businessDay': o.businessDay,
      'items': o.items.map((item) => {
        'sku': item.sku,
        'name': item.name,
        'qty': item.qty,
        'unitPrice': item.unitPrice,
        'subtotal': item.subtotal,
      }).toList(),
      'discounts': o.discounts.map((discount) => {
        'type': discount.type,
        'amount': discount.amount,
      }).toList(),
    }).toList();
    
    await prefs.setString(_ordersKey, jsonEncode(ordersData));
  }

  @override
  Future<List<Order>> getUnsyncedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString(_ordersKey);
    if (ordersString == null) return [];
    
    try {
      final ordersData = jsonDecode(ordersString) as List;
      return ordersData.map((orderData) {
        final items = (orderData['items'] as List?)?.map((item) => OrderItem(
          sku: item['sku'] ?? '',
          name: item['name'] ?? '',
          qty: item['qty'] ?? 0,
          unitPrice: (item['unitPrice'] ?? 0.0).toDouble(),
          subtotal: (item['subtotal'] ?? 0.0).toDouble(),
        )).toList() ?? [];
        
        final discounts = (orderData['discounts'] as List?)?.map((discount) => Discount(
          type: discount['type'] ?? '',
          amount: (discount['amount'] ?? 0.0).toDouble(),
        )).toList() ?? [];
        
        return Order(
          orderId: orderData['orderId'] ?? '',
          createdAt: DateTime.parse(orderData['createdAt'] ?? DateTime.now().toIso8601String()),
          synced: orderData['synced'] ?? false,
          items: items,
          discounts: discounts,
          total: (orderData['total'] ?? 0.0).toDouble(),
          businessDay: orderData['businessDay'] ?? '',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markOrderAsSynced(String orderId) async {
    final orders = await getUnsyncedOrders();
    final updatedOrders = orders.map((order) {
      if (order.orderId == orderId) {
        return Order(
          orderId: order.orderId,
          createdAt: order.createdAt,
          synced: true,
          items: order.items,
          discounts: order.discounts,
          total: order.total,
          businessDay: order.businessDay,
        );
      }
      return order;
    }).toList();
    
    final prefs = await SharedPreferences.getInstance();
    final ordersData = updatedOrders.map((o) => {
      'orderId': o.orderId,
      'createdAt': o.createdAt.toIso8601String(),
      'synced': o.synced,
      'total': o.total,
      'businessDay': o.businessDay,
      'items': o.items.map((item) => {
        'sku': item.sku,
        'name': item.name,
        'qty': item.qty,
        'unitPrice': item.unitPrice,
        'subtotal': item.subtotal,
      }).toList(),
      'discounts': o.discounts.map((discount) => {
        'type': discount.type,
        'amount': discount.amount,
      }).toList(),
    }).toList();
    
    await prefs.setString(_ordersKey, jsonEncode(ordersData));
  }

  @override
  Future<void> close() async {
    // No cleanup needed for SharedPreferences
  }

  // Helper methods for parsing simple data structures
  Map<String, dynamic> _parseSimpleMap(String str) {
    // This is a simplified parser - in production use proper JSON
    final result = <String, dynamic>{};
    final cleanStr = str.replaceAll('{', '').replaceAll('}', '');
    final pairs = cleanStr.split(',');
    for (final pair in pairs) {
      final keyValue = pair.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim();
        final value = keyValue[1].trim();
        result[key] = value;
      }
    }
    return result;
  }

  List<Map<String, dynamic>> _parseSimpleList(String str) {
    // This is a simplified parser - in production use proper JSON
    final result = <Map<String, dynamic>>[];
    final cleanStr = str.replaceAll('[', '').replaceAll(']', '');
    final items = cleanStr.split('},');
    for (final item in items) {
      final cleanItem = item.replaceAll('{', '').replaceAll('}', '');
      final pairs = cleanItem.split(',');
      final map = <String, dynamic>{};
      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final key = keyValue[0].trim();
          final value = keyValue[1].trim();
          map[key] = value;
        }
      }
      if (map.isNotEmpty) {
        result.add(map);
      }
    }
    return result;
  }
}

class MobileStorageService implements StorageService {
  // This will be implemented using the existing DatabaseService
  // For now, we'll create a simple implementation
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> saveDevice(Device device) async {
    _storage['device'] = {
      'deviceId': device.deviceId,
      'jwt': device.jwt,
      'lastSeen': device.lastSeen.toIso8601String(),
    };
  }

  @override
  Future<Device?> getDevice() async {
    final deviceData = _storage['device'];
    if (deviceData == null) return null;
    
    return Device(
      deviceId: deviceData['deviceId'] ?? '',
      jwt: deviceData['jwt'] ?? '',
      lastSeen: DateTime.parse(deviceData['lastSeen'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  Future<void> clearDevice() async {
    _storage.remove('device');
  }

  @override
  Future<void> saveMenu(Menu menu) async {
    _storage['menu'] = {
      'version': menu.version,
      'updatedAt': menu.updatedAt.toIso8601String(),
      'menu': {
        'categories': menu.menu.categories.map((category) => {
          'name': category.name,
          'items': category.items.map((item) => {
            'sku': item.sku,
            'name': item.name,
            'price': item.price,
            'available': item.available,
          }).toList(),
        }).toList(),
      },
    };
  }

  @override
  Future<Menu?> getMenu() async {
    final menuData = _storage['menu'];
    if (menuData == null) return null;
    
    final categories = (menuData['menu']?['categories'] as List?)?.map((category) => MenuCategory(
      name: category['name'] ?? '',
      items: (category['items'] as List?)?.map((item) => MenuItem(
        sku: item['sku'] ?? '',
        name: item['name'] ?? '',
        price: (item['price'] ?? 0.0).toDouble(),
        available: item['available'] ?? true,
      )).toList() ?? [],
    )).toList() ?? [];
    
    return Menu(
      version: menuData['version'] ?? 0,
      updatedAt: DateTime.parse(menuData['updatedAt'] ?? DateTime.now().toIso8601String()),
      menu: MenuData(categories: categories),
    );
  }

  @override
  Future<void> insertOrder(Order order) async {
    final orders = await getUnsyncedOrders();
    orders.add(order);
    _storage['orders'] = orders.map((o) => {
      'orderId': o.orderId,
      'createdAt': o.createdAt.toIso8601String(),
      'synced': o.synced,
      'total': o.total,
      'businessDay': o.businessDay,
      'items': o.items.map((item) => {
        'sku': item.sku,
        'name': item.name,
        'qty': item.qty,
        'unitPrice': item.unitPrice,
        'subtotal': item.subtotal,
      }).toList(),
      'discounts': o.discounts.map((discount) => {
        'type': discount.type,
        'amount': discount.amount,
      }).toList(),
    }).toList();
  }

  @override
  Future<List<Order>> getUnsyncedOrders() async {
    final ordersData = _storage['orders'] as List? ?? [];
    return ordersData.map((orderData) {
      final items = (orderData['items'] as List?)?.map((item) => OrderItem(
        sku: item['sku'] ?? '',
        name: item['name'] ?? '',
        qty: item['qty'] ?? 0,
        unitPrice: (item['unitPrice'] ?? 0.0).toDouble(),
        subtotal: (item['subtotal'] ?? 0.0).toDouble(),
      )).toList() ?? [];
      
      final discounts = (orderData['discounts'] as List?)?.map((discount) => Discount(
        type: discount['type'] ?? '',
        amount: (discount['amount'] ?? 0.0).toDouble(),
      )).toList() ?? [];
      
      return Order(
        orderId: orderData['orderId'] ?? '',
        createdAt: DateTime.parse(orderData['createdAt'] ?? DateTime.now().toIso8601String()),
        synced: orderData['synced'] ?? false,
        items: items,
        discounts: discounts,
        total: (orderData['total'] ?? 0.0).toDouble(),
        businessDay: orderData['businessDay'] ?? '',
      );
    }).toList();
  }

  @override
  Future<void> markOrderAsSynced(String orderId) async {
    final orders = await getUnsyncedOrders();
    final updatedOrders = orders.map((order) {
      if (order.orderId == orderId) {
        return Order(
          orderId: order.orderId,
          createdAt: order.createdAt,
          synced: true,
          items: order.items,
          discounts: order.discounts,
          total: order.total,
          businessDay: order.businessDay,
        );
      }
      return order;
    }).toList();
    
    _storage['orders'] = updatedOrders.map((o) => {
      'orderId': o.orderId,
      'createdAt': o.createdAt.toIso8601String(),
      'synced': o.synced,
      'total': o.total,
      'businessDay': o.businessDay,
      'items': o.items.map((item) => {
        'sku': item.sku,
        'name': item.name,
        'qty': item.qty,
        'unitPrice': item.unitPrice,
        'subtotal': item.subtotal,
      }).toList(),
      'discounts': o.discounts.map((discount) => {
        'type': discount.type,
        'amount': discount.amount,
      }).toList(),
    }).toList();
  }

  @override
  Future<void> close() async {
    _storage.clear();
  }
}

class StorageServiceFactory {
  static StorageService create() {
    if (kIsWeb) {
      return WebStorageService();
    } else {
      return MobileStorageService();
    }
  }
} 