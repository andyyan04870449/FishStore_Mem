import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final String orderId;
  final DateTime createdAt;
  final bool synced;
  final List<OrderItem> items;
  final List<Discount> discounts;
  final double total;
  final String businessDay;

  Order({
    required this.orderId,
    required this.createdAt,
    this.synced = false,
    required this.items,
    this.discounts = const [],
    required this.total,
    required this.businessDay,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  Order copyWith({
    String? orderId,
    DateTime? createdAt,
    bool? synced,
    List<OrderItem>? items,
    List<Discount>? discounts,
    double? total,
    String? businessDay,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
      items: items ?? this.items,
      discounts: discounts ?? this.discounts,
      total: total ?? this.total,
      businessDay: businessDay ?? this.businessDay,
    );
  }
}

@JsonSerializable()
class OrderItem {
  final String sku;
  final String name;
  final int qty;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.sku,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  OrderItem copyWith({
    String? sku,
    String? name,
    int? qty,
    double? unitPrice,
    double? subtotal,
  }) {
    return OrderItem(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}

@JsonSerializable()
class Discount {
  final String type;
  final double amount;

  Discount({
    required this.type,
    required this.amount,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => _$DiscountFromJson(json);
  Map<String, dynamic> toJson() => _$DiscountToJson(this);
} 