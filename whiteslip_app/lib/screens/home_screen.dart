import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/menu.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/order_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = '全部';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenuItem> _getFilteredItems() {
    final appProvider = context.read<AppProvider>();
    final menu = appProvider.menu;
    
    if (menu == null) return [];

    List<MenuItem> items = menu.items.where((item) => item.available).toList();

    // 分類篩選
    if (_selectedCategory != '全部') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    // 搜尋篩選
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      items = items.where((item) => 
        item.name.toLowerCase().contains(searchTerm) ||
        item.sku.toLowerCase().contains(searchTerm)
      ).toList();
    }

    return items;
  }

  List<String> _getCategories() {
    final appProvider = context.read<AppProvider>();
    final menu = appProvider.menu;
    
    if (menu == null) return ['全部'];

    final categories = menu.items
        .where((item) => item.available)
        .map((item) => item.category)
        .toSet()
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('菜單更新失敗'),
            backgroundColor: Colors.red,
          ),
        );
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
      body: Consumer<AppProvider>(
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
                          final item = _getFilteredItems()[index];
                          return MenuItemCard(
                            menuItem: item,
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
    );
  }
} 