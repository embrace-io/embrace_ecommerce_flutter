import 'package:equatable/equatable.dart';
import 'address.dart';
import 'payment_method.dart';
import 'shipping_method.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled, refunded }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  bool get isActive =>
      this == OrderStatus.pending ||
      this == OrderStatus.processing ||
      this == OrderStatus.shipped;
}

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final Map<String, String> selectedVariants;
  final String? imageUrl;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.selectedVariants = const {},
    this.imageUrl,
  });

  double get totalPrice => unitPrice * quantity;
  String get formattedUnitPrice => '\$${unitPrice.toStringAsFixed(2)}';
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      selectedVariants: (json['selectedVariants'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'selectedVariants': selectedVariants,
        'imageUrl': imageUrl,
      };

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        quantity,
        unitPrice,
        selectedVariants,
        imageUrl,
      ];
}

class Order extends Equatable {
  final String id;
  final String? userId;
  final String orderNumber;
  final List<OrderItem> items;
  final Address shippingAddress;
  final Address? billingAddress;
  final PaymentMethod paymentMethod;
  final ShippingMethod shippingMethod;
  final OrderStatus status;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;

  const Order({
    required this.id,
    this.userId,
    required this.orderNumber,
    required this.items,
    required this.shippingAddress,
    this.billingAddress,
    required this.paymentMethod,
    required this.shippingMethod,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedDelivery,
    this.trackingNumber,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedTax => '\$${tax.toStringAsFixed(2)}';
  String get formattedShipping =>
      shipping > 0 ? '\$${shipping.toStringAsFixed(2)}' : 'Free';
  String get formattedTotal => '\$${total.toStringAsFixed(2)}';

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      orderNumber: json['orderNumber'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingAddress:
          Address.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      billingAddress: json['billingAddress'] != null
          ? Address.fromJson(json['billingAddress'] as Map<String, dynamic>)
          : null,
      paymentMethod:
          PaymentMethod.fromJson(json['paymentMethod'] as Map<String, dynamic>),
      shippingMethod:
          ShippingMethod.fromJson(json['shippingMethod'] as Map<String, dynamic>),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'] as String)
          : null,
      trackingNumber: json['trackingNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'orderNumber': orderNumber,
        'items': items.map((i) => i.toJson()).toList(),
        'shippingAddress': shippingAddress.toJson(),
        'billingAddress': billingAddress?.toJson(),
        'paymentMethod': paymentMethod.toJson(),
        'shippingMethod': shippingMethod.toJson(),
        'status': status.name,
        'subtotal': subtotal,
        'tax': tax,
        'shipping': shipping,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'estimatedDelivery': estimatedDelivery?.toIso8601String(),
        'trackingNumber': trackingNumber,
      };

  @override
  List<Object?> get props => [
        id,
        userId,
        orderNumber,
        items,
        shippingAddress,
        billingAddress,
        paymentMethod,
        shippingMethod,
        status,
        subtotal,
        tax,
        shipping,
        total,
        createdAt,
        updatedAt,
        estimatedDelivery,
        trackingNumber,
      ];
}
