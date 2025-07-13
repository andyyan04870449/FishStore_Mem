import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable()
class Menu {
  final int version;
  @JsonKey(name: 'lastUpdated')
  final DateTime updatedAt;
  final MenuData menu;

  Menu({
    required this.version,
    required this.updatedAt,
    required this.menu,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);

  Menu copyWith({
    int? version,
    DateTime? updatedAt,
    MenuData? menu,
  }) {
    return Menu(
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      menu: menu ?? this.menu,
    );
  }
}

@JsonSerializable()
class MenuData {
  final List<MenuCategory> categories;

  MenuData({
    required this.categories,
  });

  factory MenuData.fromJson(Map<String, dynamic> json) => _$MenuDataFromJson(json);
  Map<String, dynamic> toJson() => _$MenuDataToJson(this);
}

@JsonSerializable()
class MenuCategory {
  final String name;
  final List<MenuItem> items;

  MenuCategory({
    required this.name,
    required this.items,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => _$MenuCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$MenuCategoryToJson(this);
}

@JsonSerializable()
class MenuItem {
  final String sku;
  final String name;
  final double price;
  @JsonKey(defaultValue: true)
  final bool available;

  MenuItem({
    required this.sku,
    required this.name,
    required this.price,
    this.available = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  MenuItem copyWith({
    String? sku,
    String? name,
    double? price,
    bool? available,
  }) {
    return MenuItem(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      available: available ?? this.available,
    );
  }
} 