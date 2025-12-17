import 'package:equatable/equatable.dart';

enum PaymentType { creditCard, debitCard, applePay, googlePay, paypal, stripe }

class CardInfo extends Equatable {
  final String last4;
  final String brand;
  final int expiryMonth;
  final int expiryYear;
  final String holderName;

  const CardInfo({
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.holderName,
  });

  String get displayName => '$brand **** $last4';
  String get expiry => '$expiryMonth/$expiryYear';
  bool get isExpired {
    final now = DateTime.now();
    return expiryYear < now.year ||
        (expiryYear == now.year && expiryMonth < now.month);
  }

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      last4: json['last4'] as String,
      brand: json['brand'] as String,
      expiryMonth: json['expiryMonth'] as int,
      expiryYear: json['expiryYear'] as int,
      holderName: json['holderName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'last4': last4,
        'brand': brand,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'holderName': holderName,
      };

  @override
  List<Object?> get props =>
      [last4, brand, expiryMonth, expiryYear, holderName];
}

class DigitalWalletInfo extends Equatable {
  final String walletType;
  final String? email;

  const DigitalWalletInfo({
    required this.walletType,
    this.email,
  });

  factory DigitalWalletInfo.fromJson(Map<String, dynamic> json) {
    return DigitalWalletInfo(
      walletType: json['walletType'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'walletType': walletType,
        'email': email,
      };

  @override
  List<Object?> get props => [walletType, email];
}

class PaymentMethod extends Equatable {
  final String id;
  final PaymentType type;
  final bool isDefault;
  final CardInfo? cardInfo;
  final DigitalWalletInfo? digitalWalletInfo;
  final String? stripePaymentMethodId;

  const PaymentMethod({
    required this.id,
    required this.type,
    this.isDefault = false,
    this.cardInfo,
    this.digitalWalletInfo,
    this.stripePaymentMethodId,
  });

  String get displayName {
    if (cardInfo != null) {
      return cardInfo!.displayName;
    }
    if (digitalWalletInfo != null) {
      return digitalWalletInfo!.walletType;
    }
    switch (type) {
      case PaymentType.applePay:
        return 'Apple Pay';
      case PaymentType.googlePay:
        return 'Google Pay';
      case PaymentType.paypal:
        return 'PayPal';
      default:
        return type.name;
    }
  }

  PaymentMethod copyWith({
    String? id,
    PaymentType? type,
    bool? isDefault,
    CardInfo? cardInfo,
    DigitalWalletInfo? digitalWalletInfo,
    String? stripePaymentMethodId,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      cardInfo: cardInfo ?? this.cardInfo,
      digitalWalletInfo: digitalWalletInfo ?? this.digitalWalletInfo,
      stripePaymentMethodId:
          stripePaymentMethodId ?? this.stripePaymentMethodId,
    );
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.creditCard,
      ),
      isDefault: json['isDefault'] as bool? ?? false,
      cardInfo: json['cardInfo'] != null
          ? CardInfo.fromJson(json['cardInfo'] as Map<String, dynamic>)
          : null,
      digitalWalletInfo: json['digitalWalletInfo'] != null
          ? DigitalWalletInfo.fromJson(
              json['digitalWalletInfo'] as Map<String, dynamic>)
          : null,
      stripePaymentMethodId: json['stripePaymentMethodId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'isDefault': isDefault,
        'cardInfo': cardInfo?.toJson(),
        'digitalWalletInfo': digitalWalletInfo?.toJson(),
        'stripePaymentMethodId': stripePaymentMethodId,
      };

  @override
  List<Object?> get props => [
        id,
        type,
        isDefault,
        cardInfo,
        digitalWalletInfo,
        stripePaymentMethodId,
      ];
}

enum PaymentStatus { pending, succeeded, failed, cancelled, requiresAction }

class PaymentTransaction extends Equatable {
  final String id;
  final String? paymentIntentId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final DateTime createdAt;
  final PaymentMethod paymentMethodUsed;
  final String? failureReason;

  const PaymentTransaction({
    required this.id,
    this.paymentIntentId,
    required this.amount,
    this.currency = 'USD',
    required this.status,
    required this.createdAt,
    required this.paymentMethodUsed,
    this.failureReason,
  });

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      paymentIntentId: json['paymentIntentId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      paymentMethodUsed:
          PaymentMethod.fromJson(json['paymentMethodUsed'] as Map<String, dynamic>),
      failureReason: json['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'paymentIntentId': paymentIntentId,
        'amount': amount,
        'currency': currency,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'paymentMethodUsed': paymentMethodUsed.toJson(),
        'failureReason': failureReason,
      };

  @override
  List<Object?> get props => [
        id,
        paymentIntentId,
        amount,
        currency,
        status,
        createdAt,
        paymentMethodUsed,
        failureReason,
      ];
}
