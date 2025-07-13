// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
  version: (json['version'] as num).toInt(),
  updatedAt: DateTime.parse(json['lastUpdated'] as String),
  menu: MenuData.fromJson(json['menu'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
  'version': instance.version,
  'lastUpdated': instance.updatedAt.toIso8601String(),
  'menu': instance.menu,
};

MenuData _$MenuDataFromJson(Map<String, dynamic> json) => MenuData(
  categories: (json['categories'] as List<dynamic>)
      .map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuDataToJson(MenuData instance) => <String, dynamic>{
  'categories': instance.categories,
};

MenuCategory _$MenuCategoryFromJson(Map<String, dynamic> json) => MenuCategory(
  name: json['name'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuCategoryToJson(MenuCategory instance) =>
    <String, dynamic>{'name': instance.name, 'items': instance.items};

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  sku: json['sku'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  available: json['available'] as bool? ?? true,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'sku': instance.sku,
  'name': instance.name,
  'price': instance.price,
  'available': instance.available,
};
