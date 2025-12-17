import 'package:equatable/equatable.dart';

class ShippingMethod extends Equatable {
  final String id;
  final String name;
  final String description;
  final double cost;
  final int estimatedDays;
  final bool isAvailable;
  final bool trackingIncluded;
  final bool insuranceIncluded;

  const ShippingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.estimatedDays,
    this.isAvailable = true,
    this.trackingIncluded = false,
    this.insuranceIncluded = false,
  });

  String get displayName => name;
  String get formattedCost => cost > 0 ? '\$${cost.toStringAsFixed(2)}' : 'Free';

  String get estimatedDeliveryText {
    if (estimatedDays == 1) {
      return 'Next day delivery';
    } else if (estimatedDays <= 3) {
      return '$estimatedDays-${estimatedDays + 1} business days';
    } else {
      return '$estimatedDays-${estimatedDays + 2} business days';
    }
  }

  ShippingMethod copyWith({
    String? id,
    String? name,
    String? description,
    double? cost,
    int? estimatedDays,
    bool? isAvailable,
    bool? trackingIncluded,
    bool? insuranceIncluded,
  }) {
    return ShippingMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      isAvailable: isAvailable ?? this.isAvailable,
      trackingIncluded: trackingIncluded ?? this.trackingIncluded,
      insuranceIncluded: insuranceIncluded ?? this.insuranceIncluded,
    );
  }

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toDouble(),
      estimatedDays: json['estimatedDays'] as int,
      isAvailable: json['isAvailable'] as bool? ?? true,
      trackingIncluded: json['trackingIncluded'] as bool? ?? false,
      insuranceIncluded: json['insuranceIncluded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'cost': cost,
        'estimatedDays': estimatedDays,
        'isAvailable': isAvailable,
        'trackingIncluded': trackingIncluded,
        'insuranceIncluded': insuranceIncluded,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        cost,
        estimatedDays,
        isAvailable,
        trackingIncluded,
        insuranceIncluded,
      ];
}

// Predefined shipping methods
class ShippingMethods {
  static const standard = ShippingMethod(
    id: 'standard',
    name: 'Standard Shipping',
    description: 'Regular delivery via USPS',
    cost: 5.99,
    estimatedDays: 5,
    trackingIncluded: true,
  );

  static const express = ShippingMethod(
    id: 'express',
    name: 'Express Shipping',
    description: 'Fast delivery via UPS',
    cost: 12.99,
    estimatedDays: 2,
    trackingIncluded: true,
    insuranceIncluded: true,
  );

  static const overnight = ShippingMethod(
    id: 'overnight',
    name: 'Overnight Shipping',
    description: 'Next day delivery via FedEx',
    cost: 24.99,
    estimatedDays: 1,
    trackingIncluded: true,
    insuranceIncluded: true,
  );

  static const free = ShippingMethod(
    id: 'free',
    name: 'Free Shipping',
    description: 'Free standard shipping on orders over \$50',
    cost: 0,
    estimatedDays: 7,
    trackingIncluded: true,
  );

  static List<ShippingMethod> all = [standard, express, overnight, free];
}
