import 'package:equatable/equatable.dart';

enum AuthenticationMethod { email, google, guest, biometric }

extension AuthenticationMethodExtension on AuthenticationMethod {
  String get displayName {
    switch (this) {
      case AuthenticationMethod.email:
        return 'Email';
      case AuthenticationMethod.google:
        return 'Google';
      case AuthenticationMethod.guest:
        return 'Guest';
      case AuthenticationMethod.biometric:
        return 'Biometric';
    }
  }

  String get iconName {
    switch (this) {
      case AuthenticationMethod.email:
        return 'email';
      case AuthenticationMethod.google:
        return 'google';
      case AuthenticationMethod.guest:
        return 'person_outline';
      case AuthenticationMethod.biometric:
        return 'fingerprint';
    }
  }
}

class UserPreferences extends Equatable {
  final bool newsletter;
  final bool pushNotifications;
  final bool biometricAuth;
  final String preferredCurrency;

  const UserPreferences({
    this.newsletter = false,
    this.pushNotifications = true,
    this.biometricAuth = false,
    this.preferredCurrency = 'USD',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      newsletter: json['newsletter'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      biometricAuth: json['biometricAuth'] as bool? ?? false,
      preferredCurrency: json['preferredCurrency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() => {
        'newsletter': newsletter,
        'pushNotifications': pushNotifications,
        'biometricAuth': biometricAuth,
        'preferredCurrency': preferredCurrency,
      };

  @override
  List<Object?> get props =>
      [newsletter, pushNotifications, biometricAuth, preferredCurrency];
}

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime dateJoined;
  final bool isGuest;
  final UserPreferences? preferences;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.dateJoined,
    this.isGuest = false,
    this.preferences,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => isGuest ? 'Guest' : fullName;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      dateJoined: DateTime.parse(json['dateJoined'] as String),
      isGuest: json['isGuest'] as bool? ?? false,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'dateJoined': dateJoined.toIso8601String(),
        'isGuest': isGuest,
        'preferences': preferences?.toJson(),
      };

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateJoined,
    bool? isGuest,
    UserPreferences? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateJoined: dateJoined ?? this.dateJoined,
      isGuest: isGuest ?? this.isGuest,
      preferences: preferences ?? this.preferences,
    );
  }

  factory User.guest() => User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@embrace.io',
        firstName: 'Guest',
        lastName: 'User',
        dateJoined: DateTime.now(),
        isGuest: true,
      );

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        dateJoined,
        isGuest,
        preferences,
      ];
}

class AuthenticatedUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final AuthenticationMethod authMethod;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final bool isGuest;
  final bool biometricEnabled;

  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.authMethod,
    required this.createdAt,
    required this.lastSignInAt,
    this.isGuest = false,
    this.biometricEnabled = false,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoURL: json['photoURL'] as String?,
      authMethod: AuthenticationMethod.values.firstWhere(
        (e) => e.name == json['authMethod'],
        orElse: () => AuthenticationMethod.email,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastSignInAt: DateTime.parse(json['lastSignInAt'] as String),
      isGuest: json['isGuest'] as bool? ?? false,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'authMethod': authMethod.name,
        'createdAt': createdAt.toIso8601String(),
        'lastSignInAt': lastSignInAt.toIso8601String(),
        'isGuest': isGuest,
        'biometricEnabled': biometricEnabled,
      };

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        authMethod,
        createdAt,
        lastSignInAt,
        isGuest,
        biometricEnabled,
      ];
}
