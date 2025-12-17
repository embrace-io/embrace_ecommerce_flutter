import 'dart:math';
import '../models/models.dart';

/// MockDataService - Provides mock data for the E-commerce app
///
/// This service mirrors the iOS MockDataService to provide consistent
/// product and category data for testing and demonstration.
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  static MockDataService get shared => _instance;

  MockDataService._internal();

  final Random _random = Random();

  // MARK: - Categories

  static const List<Category> _categories = [
    Category(
      id: 'electronics',
      name: 'Electronics',
      description: 'Smartphones, laptops, and gadgets',
      imageUrl: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400',
      subcategories: ['Phones', 'Laptops', 'Tablets', 'Accessories'],
    ),
    Category(
      id: 'fashion',
      name: 'Fashion',
      description: 'Clothing, shoes, and accessories',
      imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400',
      subcategories: ['Men', 'Women', 'Kids', 'Accessories'],
    ),
    Category(
      id: 'home',
      name: 'Home & Garden',
      description: 'Furniture, decor, and outdoor',
      imageUrl: 'https://images.unsplash.com/photo-1484101403633-562f891dc89a?w=400',
      subcategories: ['Furniture', 'Decor', 'Kitchen', 'Garden'],
    ),
    Category(
      id: 'sports',
      name: 'Sports & Outdoors',
      description: 'Equipment, apparel, and gear',
      imageUrl: 'https://images.unsplash.com/photo-1461896836934- voices-56f6dfbc4e?w=400',
      subcategories: ['Fitness', 'Outdoor', 'Team Sports', 'Water Sports'],
    ),
    Category(
      id: 'books',
      name: 'Books',
      description: 'Fiction, non-fiction, and more',
      imageUrl: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400',
      subcategories: ['Fiction', 'Non-Fiction', 'Education', 'Children'],
    ),
    Category(
      id: 'beauty',
      name: 'Beauty',
      description: 'Skincare, makeup, and wellness',
      imageUrl: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400',
      subcategories: ['Skincare', 'Makeup', 'Hair Care', 'Fragrance'],
    ),
  ];

  // MARK: - Products

  static final List<Product> _products = [
    // Electronics
    Product(
      id: 'prod_001',
      name: 'Wireless Bluetooth Earbuds',
      description: 'Premium wireless earbuds with active noise cancellation, 24-hour battery life, and crystal-clear audio. Perfect for music, calls, and workouts.',
      price: 149.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400',
        'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400',
      ],
      category: 'electronics',
      brand: 'TechPro',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.color, value: 'Black'),
        ProductVariant(id: 'v2', type: VariantType.color, value: 'White'),
        ProductVariant(id: 'v3', type: VariantType.color, value: 'Navy'),
      ],
      inStock: true,
      stockCount: 150,
      weight: 0.05,
      dimensions: ProductDimensions(width: 6, height: 4, depth: 3),
    ),
    Product(
      id: 'prod_002',
      name: 'Smart Watch Series X',
      description: 'Advanced smartwatch with health monitoring, GPS, and 5-day battery. Water resistant and compatible with iOS and Android.',
      price: 299.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=400',
        'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400',
      ],
      category: 'electronics',
      brand: 'TechPro',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.size, value: '40mm'),
        ProductVariant(id: 'v2', type: VariantType.size, value: '44mm'),
        ProductVariant(id: 'v3', type: VariantType.color, value: 'Space Gray'),
        ProductVariant(id: 'v4', type: VariantType.color, value: 'Silver'),
      ],
      inStock: true,
      stockCount: 75,
      weight: 0.08,
      dimensions: ProductDimensions(width: 4, height: 5, depth: 1),
    ),
    Product(
      id: 'prod_003',
      name: 'Portable Power Bank 20000mAh',
      description: 'High-capacity portable charger with fast charging support. Charge up to 3 devices simultaneously.',
      price: 49.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400',
      ],
      category: 'electronics',
      brand: 'PowerMax',
      inStock: true,
      stockCount: 200,
      weight: 0.4,
      dimensions: ProductDimensions(width: 15, height: 7, depth: 2),
    ),

    // Fashion
    Product(
      id: 'prod_004',
      name: 'Classic Leather Jacket',
      description: 'Premium genuine leather jacket with quilted lining. Timeless style for any occasion.',
      price: 249.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
        'https://images.unsplash.com/photo-1520975954732-35dd22299614?w=400',
      ],
      category: 'fashion',
      brand: 'UrbanStyle',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.size, value: 'S'),
        ProductVariant(id: 'v2', type: VariantType.size, value: 'M'),
        ProductVariant(id: 'v3', type: VariantType.size, value: 'L'),
        ProductVariant(id: 'v4', type: VariantType.size, value: 'XL'),
        ProductVariant(id: 'v5', type: VariantType.color, value: 'Black'),
        ProductVariant(id: 'v6', type: VariantType.color, value: 'Brown'),
      ],
      inStock: true,
      stockCount: 45,
      weight: 1.2,
      dimensions: ProductDimensions(width: 50, height: 70, depth: 5),
    ),
    Product(
      id: 'prod_005',
      name: 'Running Sneakers Pro',
      description: 'Lightweight running shoes with responsive cushioning and breathable mesh upper. Designed for performance.',
      price: 129.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
        'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=400',
      ],
      category: 'fashion',
      brand: 'SpeedRun',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.size, value: '8'),
        ProductVariant(id: 'v2', type: VariantType.size, value: '9'),
        ProductVariant(id: 'v3', type: VariantType.size, value: '10'),
        ProductVariant(id: 'v4', type: VariantType.size, value: '11'),
        ProductVariant(id: 'v5', type: VariantType.color, value: 'Red/Black'),
        ProductVariant(id: 'v6', type: VariantType.color, value: 'Blue/White'),
      ],
      inStock: true,
      stockCount: 120,
      weight: 0.6,
      dimensions: ProductDimensions(width: 30, height: 12, depth: 10),
    ),

    // Home & Garden
    Product(
      id: 'prod_006',
      name: 'Modern Floor Lamp',
      description: 'Sleek floor lamp with adjustable brightness and color temperature. Perfect for reading or ambient lighting.',
      price: 89.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400',
      ],
      category: 'home',
      brand: 'LightCraft',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.color, value: 'Black'),
        ProductVariant(id: 'v2', type: VariantType.color, value: 'White'),
        ProductVariant(id: 'v3', type: VariantType.color, value: 'Brass'),
      ],
      inStock: true,
      stockCount: 60,
      weight: 3.5,
      dimensions: ProductDimensions(width: 30, height: 150, depth: 30),
    ),
    Product(
      id: 'prod_007',
      name: 'Ceramic Plant Pot Set',
      description: 'Set of 3 minimalist ceramic pots with drainage holes. Perfect for succulents and small plants.',
      price: 34.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400',
      ],
      category: 'home',
      brand: 'GreenLife',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.color, value: 'White'),
        ProductVariant(id: 'v2', type: VariantType.color, value: 'Terracotta'),
        ProductVariant(id: 'v3', type: VariantType.color, value: 'Gray'),
      ],
      inStock: true,
      stockCount: 180,
      weight: 1.8,
      dimensions: ProductDimensions(width: 25, height: 20, depth: 25),
    ),

    // Sports
    Product(
      id: 'prod_008',
      name: 'Yoga Mat Premium',
      description: 'Extra thick, non-slip yoga mat with alignment lines. Eco-friendly TPE material.',
      price: 45.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400',
      ],
      category: 'sports',
      brand: 'ZenFit',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.color, value: 'Purple'),
        ProductVariant(id: 'v2', type: VariantType.color, value: 'Blue'),
        ProductVariant(id: 'v3', type: VariantType.color, value: 'Green'),
        ProductVariant(id: 'v4', type: VariantType.color, value: 'Pink'),
      ],
      inStock: true,
      stockCount: 95,
      weight: 1.0,
      dimensions: ProductDimensions(width: 183, height: 61, depth: 0.6),
    ),
    Product(
      id: 'prod_009',
      name: 'Resistance Bands Set',
      description: 'Complete set of 5 resistance bands with different tension levels. Includes carrying bag and exercise guide.',
      price: 24.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400',
      ],
      category: 'sports',
      brand: 'FlexForce',
      inStock: true,
      stockCount: 250,
      weight: 0.3,
      dimensions: ProductDimensions(width: 15, height: 10, depth: 5),
    ),

    // Books
    Product(
      id: 'prod_010',
      name: 'The Art of Programming',
      description: 'Comprehensive guide to software development best practices. Perfect for beginners and experienced developers.',
      price: 39.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
      ],
      category: 'books',
      brand: 'TechBooks',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.style, value: 'Hardcover'),
        ProductVariant(id: 'v2', type: VariantType.style, value: 'Paperback'),
        ProductVariant(id: 'v3', type: VariantType.style, value: 'E-Book'),
      ],
      inStock: true,
      stockCount: 300,
      weight: 0.8,
      dimensions: ProductDimensions(width: 15, height: 23, depth: 3),
    ),

    // Beauty
    Product(
      id: 'prod_011',
      name: 'Hydrating Face Serum',
      description: 'Lightweight serum with hyaluronic acid for deep hydration. Suitable for all skin types.',
      price: 54.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400',
      ],
      category: 'beauty',
      brand: 'GlowSkin',
      inStock: true,
      stockCount: 85,
      weight: 0.1,
      dimensions: ProductDimensions(width: 4, height: 10, depth: 4),
    ),
    Product(
      id: 'prod_012',
      name: 'Natural Lip Balm Set',
      description: 'Set of 4 organic lip balms with natural ingredients. Moisturizes and protects lips.',
      price: 18.99,
      imageUrls: [
        'https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=400',
      ],
      category: 'beauty',
      brand: 'PureBeauty',
      variants: [
        ProductVariant(id: 'v1', type: VariantType.style, value: 'Original'),
        ProductVariant(id: 'v2', type: VariantType.style, value: 'Tinted'),
      ],
      inStock: true,
      stockCount: 200,
      weight: 0.05,
      dimensions: ProductDimensions(width: 8, height: 8, depth: 3),
    ),
  ];

  // MARK: - Public Methods

  List<Category> getCategories() => List.unmodifiable(_categories);

  List<String> getCategoryNames() => _categories.map((c) => c.name).toList();

  List<Product> getAllProducts() => List.unmodifiable(_products);

  List<Product> getFeaturedProducts() {
    // Return first 4 products as featured
    return _products.take(4).toList();
  }

  List<Product> getNewArrivals() {
    // Return last 4 products as new arrivals
    return _products.reversed.take(4).toList();
  }

  List<Product> getDailyDeals() {
    // Return random selection of products
    final shuffled = List<Product>.from(_products)..shuffle(_random);
    return shuffled.take(3).toList();
  }

  List<Product> getProducts({String? category, int? limit, int? offset}) {
    var result = _products.toList();

    if (category != null && category.isNotEmpty) {
      result = result
          .where((p) => p.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (offset != null && offset > 0) {
      result = result.skip(offset).toList();
    }

    if (limit != null && limit > 0) {
      result = result.take(limit).toList();
    }

    return result;
  }

  Product? getProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return _products.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.description.toLowerCase().contains(lowerQuery) ||
          p.category.toLowerCase().contains(lowerQuery) ||
          (p.brand?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<Product> getRelatedProducts(String productId, {int limit = 4}) {
    final product = getProduct(productId);
    if (product == null) return [];

    return _products
        .where((p) => p.id != productId && p.category == product.category)
        .take(limit)
        .toList();
  }

  // MARK: - Mock Delays

  Duration getRandomDelay() {
    return Duration(milliseconds: 200 + _random.nextInt(800));
  }

  Future<T> withSimulatedDelay<T>(T Function() operation) async {
    await Future.delayed(getRandomDelay());
    return operation();
  }
}
