import 'package:equatable/equatable.dart';

enum AddressType { shipping, billing, both }

class Address extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String street;
  final String? street2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;
  final AddressType type;

  const Address({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.street,
    this.street2,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'United States',
    this.isDefault = false,
    this.type = AddressType.both,
  });

  String get fullName => '$firstName $lastName';

  String get formattedAddress {
    final buffer = StringBuffer();
    buffer.writeln(fullName);
    buffer.writeln(street);
    if (street2 != null && street2!.isNotEmpty) {
      buffer.writeln(street2);
    }
    buffer.write('$city, $state $zipCode');
    return buffer.toString();
  }

  String get shortAddress => '$street, $city, $state $zipCode';

  Address copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? street,
    String? street2,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
    AddressType? type,
  }) {
    return Address(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      street: street ?? this.street,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      street: json['street'] as String,
      street2: json['street2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String? ?? 'United States',
      isDefault: json['isDefault'] as bool? ?? false,
      type: AddressType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AddressType.both,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'street': street,
        'street2': street2,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'country': country,
        'isDefault': isDefault,
        'type': type.name,
      };

  factory Address.empty() => Address(
        id: '',
        firstName: '',
        lastName: '',
        street: '',
        city: '',
        state: '',
        zipCode: '',
      );

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        street,
        street2,
        city,
        state,
        zipCode,
        country,
        isDefault,
        type,
      ];
}
