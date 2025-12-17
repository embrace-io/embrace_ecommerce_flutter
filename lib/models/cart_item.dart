import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final String id;
  final String productId;
  final int quantity;
  final Map<String, String> selectedVariants;
  final DateTime addedAt;
  final double unitPrice;
  final Product product;

  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    this.selectedVariants = const {},
    required this.addedAt,
    required this.unitPrice,
    required this.product,
  });

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    int? quantity,
    Map<String, String>? selectedVariants,
    DateTime? addedAt,
    double? unitPrice,
    Product? product,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      addedAt: addedAt ?? this.addedAt,
      unitPrice: unitPrice ?? this.unitPrice,
      product: product ?? this.product,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      selectedVariants: (json['selectedVariants'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      addedAt: DateTime.parse(json['addedAt'] as String),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'quantity': quantity,
        'selectedVariants': selectedVariants,
        'addedAt': addedAt.toIso8601String(),
        'unitPrice': unitPrice,
        'product': product.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        productId,
        quantity,
        selectedVariants,
        addedAt,
        unitPrice,
        product,
      ];
}

class Cart extends Equatable {
  final String id;
  final String? userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    this.userId,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';

  bool get isEmpty => items.isEmpty;

  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Cart.empty() => Cart(
        id: '',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  @override
  List<Object?> get props => [id, userId, items, createdAt, updatedAt];
}
