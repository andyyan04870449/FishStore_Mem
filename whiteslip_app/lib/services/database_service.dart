import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/order.dart';
import '../models/menu.dart';
import '../models/auth.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'whiteslip.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 訂單表
    await db.execute('''
      CREATE TABLE orders (
        order_id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        total REAL NOT NULL,
        business_day TEXT NOT NULL
      )
    ''');

    // 訂單項目表
    await db.execute('''
      CREATE TABLE order_items (
        order_id TEXT NOT NULL,
        line_no INTEGER NOT NULL,
        sku TEXT NOT NULL,
        name TEXT NOT NULL,
        qty INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        PRIMARY KEY (order_id, line_no),
        FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE
      )
    ''');

    // 折扣表
    await db.execute('''
      CREATE TABLE discounts (
        order_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE
      )
    ''');

    // 菜單表
    await db.execute('''
      CREATE TABLE menu (
        sku TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        available INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 菜單版本表
    await db.execute('''
      CREATE TABLE menu_version (
        version INTEGER PRIMARY KEY,
        updated_at TEXT NOT NULL
      )
    ''');

    // 裝置表
    await db.execute('''
      CREATE TABLE device (
        device_id TEXT PRIMARY KEY,
        jwt TEXT NOT NULL,
        last_seen TEXT NOT NULL
      )
    ''');

    // 建立索引
    await db.execute('CREATE INDEX idx_orders_synced ON orders (synced)');
    await db.execute('CREATE INDEX idx_orders_business_day ON orders (business_day)');
    await db.execute('CREATE INDEX idx_menu_category ON menu (category)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未來版本升級邏輯
  }

  // 訂單相關操作
  Future<void> insertOrder(Order order) async {
    final db = await database;
    await db.transaction((txn) async {
      // 插入訂單
      await txn.insert('orders', {
        'order_id': order.orderId,
        'created_at': order.createdAt.toIso8601String(),
        'synced': order.synced ? 1 : 0,
        'total': order.total,
        'business_day': order.businessDay,
      });

      // 插入訂單項目
      for (int i = 0; i < order.items.length; i++) {
        final item = order.items[i];
        await txn.insert('order_items', {
          'order_id': order.orderId,
          'line_no': i,
          'sku': item.sku,
          'name': item.name,
          'qty': item.qty,
          'unit_price': item.unitPrice,
          'subtotal': item.subtotal,
        });
      }

      // 插入折扣
      for (final discount in order.discounts) {
        await txn.insert('discounts', {
          'order_id': order.orderId,
          'type': discount.type,
          'amount': discount.amount,
        });
      }
    });
  }

  Future<List<Order>> getUnsyncedOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'synced = ?',
      whereArgs: [0],
    );

    List<Order> orders = [];
    for (final map in maps) {
      final orderId = map['order_id'] as String;
      final items = await _getOrderItems(orderId);
      final discounts = await _getOrderDiscounts(orderId);
      
      orders.add(Order(
        orderId: orderId,
        createdAt: DateTime.parse(map['created_at'] as String),
        synced: map['synced'] == 1,
        items: items,
        discounts: discounts,
        total: map['total'] as double,
        businessDay: map['business_day'] as String,
      ));
    }
    return orders;
  }

  Future<List<OrderItem>> _getOrderItems(String orderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'line_no ASC',
    );

    return maps.map((map) => OrderItem(
      sku: map['sku'] as String,
      name: map['name'] as String,
      qty: map['qty'] as int,
      unitPrice: map['unit_price'] as double,
      subtotal: map['subtotal'] as double,
    )).toList();
  }

  Future<List<Discount>> _getOrderDiscounts(String orderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'discounts',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    return maps.map((map) => Discount(
      type: map['type'] as String,
      amount: map['amount'] as double,
    )).toList();
  }

  Future<void> markOrderAsSynced(String orderId) async {
    final db = await database;
    await db.update(
      'orders',
      {'synced': 1},
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  // 菜單相關操作
  Future<void> saveMenu(Menu menu) async {
    final db = await database;
    await db.transaction((txn) async {
      // 清除舊菜單
      await txn.delete('menu');
      
      // 插入新菜單項目
      for (final item in menu.items) {
        await txn.insert('menu', {
          'sku': item.sku,
          'name': item.name,
          'price': item.price,
          'category': item.category,
          'available': item.available ? 1 : 0,
        });
      }

      // 更新版本
      await txn.delete('menu_version');
      await txn.insert('menu_version', {
        'version': menu.version,
        'updated_at': menu.updatedAt.toIso8601String(),
      });
    });
  }

  Future<Menu?> getMenu() async {
    final db = await database;
    final List<Map<String, dynamic>> versionMaps = await db.query('menu_version');
    if (versionMaps.isEmpty) return null;

    final List<Map<String, dynamic>> itemMaps = await db.query('menu');
    final items = itemMaps.map((map) => MenuItem(
      sku: map['sku'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      category: map['category'] as String,
      available: map['available'] == 1,
    )).toList();

    return Menu(
      version: versionMaps.first['version'] as int,
      updatedAt: DateTime.parse(versionMaps.first['updated_at'] as String),
      items: items,
    );
  }

  // 裝置相關操作
  Future<void> saveDevice(Device device) async {
    final db = await database;
    await db.insert(
      'device',
      {
        'device_id': device.deviceId,
        'jwt': device.jwt,
        'last_seen': device.lastSeen.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Device?> getDevice() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('device');
    if (maps.isEmpty) return null;

    final map = maps.first;
    return Device(
      deviceId: map['device_id'] as String,
      jwt: map['jwt'] as String,
      lastSeen: DateTime.parse(map['last_seen'] as String),
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
} 