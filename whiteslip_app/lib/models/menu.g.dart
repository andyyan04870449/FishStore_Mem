// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
  version: (json['version'] as num).toInt(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  items: (json['items'] as List<dynamic>)
      .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
  'version': instance.version,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'items': instance.items,
};

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  sku: json['sku'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  category: json['category'] as String,
  available: json['available'] as bool? ?? true,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'sku': instance.sku,
  'name': instance.name,
  'price': instance.price,
  'category': instance.category,
  'available': instance.available,
};
