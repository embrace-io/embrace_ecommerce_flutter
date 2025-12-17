import 'package:equatable/equatable.dart';

enum VariantType { size, color, style }

class ProductVariant extends Equatable {
  final String id;
  final VariantType type;
  final String value;
  final double? priceAdjustment;

  const ProductVariant({
    required this.id,
    required this.type,
    required this.value,
    this.priceAdjustment,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      type: VariantType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => VariantType.size,
      ),
      value: json['value'] as String,
      priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'value': value,
        'priceAdjustment': priceAdjustment,
      };

  @override
  List<Object?> get props => [id, type, value, priceAdjustment];
}

class ProductDimensions extends Equatable {
  final double width;
  final double height;
  final double depth;

  const ProductDimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  double get volume => width * height * depth;
  bool get isOversized => volume > 10000;

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      depth: (json['depth'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'depth': depth,
      };

  @override
  List<Object?> get props => [width, height, depth];
}

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String category;
  final String? brand;
  final List<ProductVariant> variants;
  final bool inStock;
  final int? stockCount;
  final double weight;
  final ProductDimensions dimensions;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.imageUrls,
    required this.category,
    this.brand,
    this.variants = const [],
    this.inStock = true,
    this.stockCount,
    this.weight = 0.0,
    required this.dimensions,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get primaryImageUrl =>
      imageUrls.isNotEmpty ? imageUrls.first : 'https://via.placeholder.com/300';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String,
      brand: json['brand'] as String?,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      inStock: json['inStock'] as bool? ?? true,
      stockCount: json['stockCount'] as int?,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: json['dimensions'] != null
          ? ProductDimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
          : const ProductDimensions(width: 10, height: 10, depth: 10),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'currency': currency,
        'imageUrls': imageUrls,
        'category': category,
        'brand': brand,
        'variants': variants.map((v) => v.toJson()).toList(),
        'inStock': inStock,
        'stockCount': stockCount,
        'weight': weight,
        'dimensions': dimensions.toJson(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        currency,
        imageUrls,
        category,
        brand,
        variants,
        inStock,
        stockCount,
        weight,
        dimensions,
      ];
}

class Category extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<String> subcategories;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.subcategories = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'subcategories': subcategories,
      };

  @override
  List<Object?> get props => [id, name, description, imageUrl, subcategories];
}
