import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// AuthProvider - Manages authentication state
///
/// Provides authentication functionality with Embrace telemetry.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.shared;
  final EmbraceService _embrace = EmbraceService.shared;

  AuthState _state = AuthState.initial;
  AuthenticatedUser? _currentUser;
  String? _errorMessage;
  bool _biometricAvailable = false;

  AuthState get state => _state;
  AuthenticatedUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get biometricAvailable => _biometricAvailable;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      // Check for saved user session
      final savedUser = await _authService.getSavedUser();
      if (savedUser != null) {
        _currentUser = savedUser;
        _state = AuthState.authenticated;
        await _embrace.setUserIdentifier(savedUser.id);
        await _embrace.addSessionProperty('user_id', savedUser.id);
        await _embrace.addSessionProperty('auth_method', savedUser.authMethod.name);
      } else {
        _state = AuthState.unauthenticated;
      }

      // Check biometric availability
      _biometricAvailable = await _authService.isBiometricAvailable();
    } catch (e) {
      _state = AuthState.unauthenticated;
      debugPrint('Error initializing auth: $e');
    }

    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmail(email, password);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.registerWithEmail(
        email,
        password,
        displayName,
      );
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithGoogle();
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithBiometric() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithBiometric();
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> continueAsGuest() async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.continueAsGuest();
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to continue as guest';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _currentUser != null
          ? AuthState.authenticated
          : AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
