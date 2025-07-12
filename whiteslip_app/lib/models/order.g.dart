// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  orderId: json['orderId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  synced: json['synced'] as bool? ?? false,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  discounts:
      (json['discounts'] as List<dynamic>?)
          ?.map((e) => Discount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  total: (json['total'] as num).toDouble(),
  businessDay: json['businessDay'] as String,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'orderId': instance.orderId,
  'createdAt': instance.createdAt.toIso8601String(),
  'synced': instance.synced,
  'items': instance.items,
  'discounts': instance.discounts,
  'total': instance.total,
  'businessDay': instance.businessDay,
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  sku: json['sku'] as String,
  name: json['name'] as String,
  qty: (json['qty'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  subtotal: (json['subtotal'] as num).toDouble(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'sku': instance.sku,
  'name': instance.name,
  'qty': instance.qty,
  'unitPrice': instance.unitPrice,
  'subtotal': instance.subtotal,
};

Discount _$DiscountFromJson(Map<String, dynamic> json) => Discount(
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$DiscountToJson(Discount instance) => <String, dynamic>{
  'type': instance.type,
  'amount': instance.amount,
};
