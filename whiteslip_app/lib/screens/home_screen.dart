import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/menu.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/order_summary.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = '全部';
  final TextEditingController _searchController = TextEditingController();

  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });

    // 監聽認證狀態變化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = context.read<AppProvider>();
      appProvider.addListener(_onAuthStateChanged);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    
    // 移除認證狀態監聽
    final appProvider = context.read<AppProvider>();
    appProvider.removeListener(_onAuthStateChanged);
    
    super.dispose();
  }

  void _onAuthStateChanged() {
    final appProvider = context.read<AppProvider>();
    
    // 如果未認證且不在載入中，導向登入頁面
    if (!appProvider.isAuthenticated && !appProvider.isLoading && mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  List<MapEntry<MenuItem, String>> _getFilteredItems() {
    final appProvider = context.read<AppProvider>();
    final menu = appProvider.menu;
    
    if (menu == null) return [];

    // 從所有分類中收集所有項目及其分類
    List<MapEntry<MenuItem, String>> allItems = [];
    for (final category in menu.menu.categories) {
      for (final item in category.items.where((item) => item.available)) {
        allItems.add(MapEntry(item, category.name));
      }
    }

    // 分類篩選
    if (_selectedCategory != '全部') {
      allItems = allItems.where((entry) => entry.value == _selectedCategory).toList();
    }

    // 搜尋篩選
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      allItems = allItems.where((entry) => 
        entry.key.name.toLowerCase().contains(searchTerm) ||
        entry.key.sku.toLowerCase().contains(searchTerm)
      ).toList();
    }

    return allItems;
  }

  List<String> _getCategories() {
    final appProvider = context.read<AppProvider>();
    final menu = appProvider.menu;
    
    if (menu == null) return ['全部'];

    final categories = menu.menu.categories
        .where((category) => category.items.any((item) => item.available))
        .map((category) => category.name)
        .toList();
    
    categories.sort();
    return ['全部', ...categories];
  }

  Future<void> _printOrder() async {
    final appProvider = context.read<AppProvider>();
    
    if (appProvider.currentOrderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請先選擇商品'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await appProvider.printOrder();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('列印成功！'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('列印失敗，請重試'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMenu() async {
    final appProvider = context.read<AppProvider>();
    final success = await appProvider.updateMenu();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('菜單更新成功'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 檢查是否因為認證問題失敗
        if (!appProvider.isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('認證已失效，請重新登入'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('菜單更新失敗，請檢查網路連線'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('白單機點餐系統'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // 網路狀態指示器
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: provider.isOnline ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.isOnline ? '線上' : '離線',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
          // 更新菜單按鈕
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateMenu,
            tooltip: '更新菜單',
          ),
          // 登出按鈕
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AppProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: '登出',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  _now.toLocal().toString().substring(0, 19),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.menu == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.menu_book,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '菜單載入中...',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateMenu,
                    child: const Text('重新載入'),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              // 左側：菜單區域
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // 搜尋和分類篩選
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // 搜尋框
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: '搜尋商品...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          // 分類篩選
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _getCategories().length,
                              itemBuilder: (context, index) {
                                final category = _getCategories()[index];
                                final isSelected = category == _selectedCategory;
                                
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(category),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedCategory = category;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 商品列表
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _getFilteredItems().length,
                        itemBuilder: (context, index) {
                                final entry = _getFilteredItems()[index];
                                final item = entry.key;
                                final category = entry.value;
                          return MenuItemCard(
                            menuItem: item,
                                  category: category,
                            onTap: () => provider.addItemToOrder(item),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // 右側：訂單摘要
              Expanded(
                flex: 1,
                child: OrderSummary(
                  onPrint: _printOrder,
                  onClear: () => provider.clearOrder(),
                ),
              ),
            ],
          );
        },
            ),
          ),
        ],
      ),
    );
  }
} 