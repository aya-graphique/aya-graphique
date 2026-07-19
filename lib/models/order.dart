/// A single line within an order — mirrors a row in `order_items`.
class OrderItem {
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productName: map['product_name'] as String? ?? 'Item',
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
    );
  }
}

/// A placed order — mirrors a row in `orders`, with its `order_items` rows
/// nested in [items].
class Order {
  final String id;
  final String fullName;
  final String email;
  final String address;
  final String phone1;
  final String phone2;
  final String paymentMethod;
  final String paymentSenderInfo;
  final bool isCompleted;
  final double subtotal;
  final double shipping;
  final double total;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.fullName,
    required this.email,
    required this.address,
    this.phone1 = '',
    this.phone2 = '',
    this.paymentMethod = 'cod',
    this.paymentSenderInfo = '',
    this.isCompleted = false,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['order_items'] as List?) ?? const [];
    return Order(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone1: map['phone_1'] as String? ?? '',
      phone2: map['phone_2'] as String? ?? '',
      paymentMethod: map['payment_method'] as String? ?? 'cod',
      paymentSenderInfo: map['payment_sender_info'] as String? ?? '',
      isCompleted: map['is_completed'] as bool? ?? false,
      subtotal: (map['subtotal'] as num).toDouble(),
      shipping: (map['shipping'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      items: rawItems
          .map((row) => OrderItem.fromMap(row as Map<String, dynamic>))
          .toList(),
    );
  }

  Order copyWith({bool? isCompleted}) {
    return Order(
      id: id,
      fullName: fullName,
      email: email,
      address: address,
      phone1: phone1,
      phone2: phone2,
      paymentMethod: paymentMethod,
      paymentSenderInfo: paymentSenderInfo,
      isCompleted: isCompleted ?? this.isCompleted,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      createdAt: createdAt,
      items: items,
    );
  }
}
