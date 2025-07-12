import 'package:json_annotation/json_annotation.dart';

part 'menu.g.dart';

@JsonSerializable()
class Menu {
  final int version;
  final DateTime updatedAt;
  final List<MenuItem> items;

  Menu({
    required this.version,
    required this.updatedAt,
    required this.items,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);

  Menu copyWith({
    int? version,
    DateTime? updatedAt,
    List<MenuItem>? items,
  }) {
    return Menu(
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

@JsonSerializable()
class MenuItem {
  final String sku;
  final String name;
  final double price;
  final String category;
  final bool available;

  MenuItem({
    required this.sku,
    required this.name,
    required this.price,
    required this.category,
    this.available = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  MenuItem copyWith({
    String? sku,
    String? name,
    double? price,
    String? category,
    bool? available,
  }) {
    return MenuItem(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      available: available ?? this.available,
    );
  }
} 