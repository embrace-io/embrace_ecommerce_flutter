import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'embrace_service.dart';

/// AuthService - Handles authentication operations
///
/// Provides email, Google, biometric, and guest authentication
/// with Embrace telemetry integration.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get shared => _instance;

  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final EmbraceService _embrace = EmbraceService.shared;

  static const String _userKey = 'authenticated_user';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // MARK: - Email Authentication

  Future<AuthenticatedUser> signInWithEmail(
    String email,
    String password,
  ) async {
    await _embrace.trackLoginAttempt('email');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock validation
    if (email.isEmpty || !email.contains('@')) {
      await _embrace.trackLoginFailure('email', 'Invalid email format');
      throw AuthException('Invalid email format');
    }

    if (password.isEmpty || password.length < 6) {
      await _embrace.trackLoginFailure('email', 'Password too short');
      throw AuthException('Password must be at least 6 characters');
    }

    // Create authenticated user
    final user = AuthenticatedUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@').first,
      authMethod: AuthenticationMethod.email,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
    );

    await _saveUser(user);
    await _embrace.trackLoginSuccess(user.id, 'email');

    return user;
  }

  Future<AuthenticatedUser> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    await _embrace.trackLoginAttempt('email_registration');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock validation
    if (email.isEmpty || !email.contains('@')) {
      await _embrace.trackLoginFailure('email_registration', 'Invalid email format');
      throw AuthException('Invalid email format');
    }

    if (password.isEmpty || password.length < 6) {
      await _embrace.trackLoginFailure('email_registration', 'Password too short');
      throw AuthException('Password must be at least 6 characters');
    }

    if (displayName.isEmpty) {
      await _embrace.trackLoginFailure('email_registration', 'Display name required');
      throw AuthException('Display name is required');
    }

    // Create authenticated user
    final user = AuthenticatedUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      authMethod: AuthenticationMethod.email,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
    );

    await _saveUser(user);
    await _embrace.trackLoginSuccess(user.id, 'email_registration');

    return user;
  }

  // MARK: - Google Sign-In

  Future<AuthenticatedUser> signInWithGoogle() async {
    await _embrace.trackLoginAttempt('google');

    try {
      // Simulate network delay for Google sign-in
      await Future.delayed(const Duration(milliseconds: 1200));

      // In a real app, you would use google_sign_in package
      // For demo purposes, we create a mock user
      final user = AuthenticatedUser(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'demo@gmail.com',
        displayName: 'Google User',
        photoURL: 'https://via.placeholder.com/100',
        authMethod: AuthenticationMethod.google,
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
      );

      await _saveUser(user);
      await _embrace.trackLoginSuccess(user.id, 'google');

      return user;
    } catch (e) {
      await _embrace.trackLoginFailure('google', e.toString());
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  // MARK: - Biometric Authentication

  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticate && isDeviceSupported;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  Future<AuthenticatedUser> signInWithBiometric() async {
    await _embrace.trackLoginAttempt('biometric');

    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        await _embrace.trackLoginFailure('biometric', 'Biometric not available');
        throw AuthException('Biometric authentication is not available');
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to sign in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!didAuthenticate) {
        await _embrace.trackLoginFailure('biometric', 'Authentication failed');
        throw AuthException('Biometric authentication failed');
      }

      // Try to get saved user or create new one
      final savedUser = await getSavedUser();
      if (savedUser != null) {
        await _embrace.trackLoginSuccess(savedUser.id, 'biometric');
        return savedUser;
      }

      // Create new user for biometric-only authentication
      final user = AuthenticatedUser(
        id: 'bio_${DateTime.now().millisecondsSinceEpoch}',
        email: 'biometric@local.device',
        displayName: 'Biometric User',
        authMethod: AuthenticationMethod.biometric,
        createdAt: DateTime.now(),
        lastSignInAt: DateTime.now(),
        biometricEnabled: true,
      );

      await _saveUser(user);
      await _embrace.trackLoginSuccess(user.id, 'biometric');

      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      await _embrace.trackLoginFailure('biometric', e.toString());
      throw AuthException('Biometric authentication error: ${e.toString()}');
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // MARK: - Guest Authentication

  Future<AuthenticatedUser> continueAsGuest() async {
    await _embrace.trackLoginAttempt('guest');

    final user = AuthenticatedUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@embrace.io',
      displayName: 'Guest',
      authMethod: AuthenticationMethod.guest,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      isGuest: true,
    );

    await _saveUser(user);
    await _embrace.trackLoginSuccess(user.id, 'guest');

    return user;
  }

  // MARK: - Sign Out

  Future<void> signOut() async {
    await _embrace.trackLogout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // MARK: - User Persistence

  Future<void> _saveUser(AuthenticatedUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<AuthenticatedUser?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      return AuthenticatedUser.fromJson(jsonDecode(userJson));
    } catch (e) {
      debugPrint('Error loading saved user: $e');
      return null;
    }
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
