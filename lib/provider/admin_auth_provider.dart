import 'package:flutter/material.dart';
import '../services/admin_auth_service.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
}

class AdminAuthProvider extends ChangeNotifier {
  final AdminAuthService _authService = AdminAuthService();
  
  AuthStatus _status = AuthStatus.unknown;
  Map<String, dynamic>? _adminData;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  Map<String, dynamic>? get adminData => _adminData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get adminName => _adminData?['name'];
  String? get adminUsername => _adminData?['username'];
  String? get adminRole => _adminData?['role'];

  // Initialize authentication state
  Future<void> initializeAuth() async {
    print('=== INITIALIZING AUTH ===');
    _setStatus(AuthStatus.loading);

    try {
      // Add timeout to prevent infinite loading
      await Future.any([
        _performAuthInit(),
        Future.delayed(const Duration(seconds: 8)).then((_) {
          throw Exception('Authentication initialization timeout');
        }),
      ]);
    } catch (e) {
      print('Auth initialization error: $e');
      _setErrorMessage('Failed to initialize authentication: $e');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<void> _performAuthInit() async {
    // Check for debug mode (bypass auth for testing)
    const bool debugMode = false; // Set to true to bypass authentication

    if (debugMode) {
      print('DEBUG MODE: Bypassing authentication');
      _adminData = {
        'id': 1,
        'username': 'debug_admin',
        'name': 'Debug Administrator',
        'role': 'super_admin',
        'isActive': true,
      };
      _setStatus(AuthStatus.authenticated);
      return;
    }

    if (_authService.isAuthenticated()) {
      print('Found existing tokens, validating session...');
      final isValid = await _authService.validateSession();

      if (isValid) {
        print('Session is valid, getting admin data...');
        _adminData = await _authService.getAdminInfo();
        _setStatus(AuthStatus.authenticated);
        print('Auth initialization successful: ${_adminData?['username']}');
      } else {
        print('Session validation failed');
        _setStatus(AuthStatus.unauthenticated);
      }
    } else {
      print('No existing tokens found');
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // Login
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    print('=== LOGIN ATTEMPT ===');
    print('Username: $username');
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(
        username: username,
        password: password,
      );
      
      if (result['success'] == true) {
        _adminData = result['admin'];
        _setStatus(AuthStatus.authenticated);
        print('Login successful: ${_adminData?['username']}');
        print('Admin data received: $_adminData');
        print('Admin name: ${_adminData?['name']}');
        print('Admin role: ${_adminData?['role']}');
        return true;
      } else {
        _setErrorMessage(result['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      _setErrorMessage(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    print('=== LOGOUT ===');
    _setLoading(true);
    
    try {
      await _authService.logout();
      _adminData = null;
      _setStatus(AuthStatus.unauthenticated);
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      // Still clear local state even if API call fails
      _adminData = null;
      _setStatus(AuthStatus.unauthenticated);
    } finally {
      _setLoading(false);
    }
  }

  // Refresh admin data
  Future<void> refreshAdminData() async {
    if (!isAuthenticated) return;
    
    try {
      _adminData = await _authService.getAdminInfo();
      notifyListeners();
      print('Admin data refreshed: ${_adminData?['username']}');
    } catch (e) {
      print('Failed to refresh admin data: $e');
      // If refresh fails, user might need to login again
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // Check if session is still valid
  Future<bool> validateSession() async {
    if (!isAuthenticated) return false;
    
    try {
      final isValid = await _authService.validateSession();
      if (!isValid) {
        _setStatus(AuthStatus.unauthenticated);
        _adminData = null;
      }
      return isValid;
    } catch (e) {
      print('Session validation error: $e');
      _setStatus(AuthStatus.unauthenticated);
      _adminData = null;
      return false;
    }
  }

  // Private helper methods
  void _setStatus(AuthStatus status) {
    if (_status != status) {
      _status = status;
      print('Auth status changed to: $status');
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    if (message != null) {
      print('Auth error: $message');
    }
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Clear error message manually
  void clearError() {
    _clearError();
  }

  // Get access token for API calls
  String? getAccessToken() {
    return _authService.getAccessToken();
  }

  // Check if admin has specific role
  bool hasRole(String role) {
    return _adminData?['role'] == role;
  }

  // Check if admin is super admin
  bool isSuperAdmin() {
    return hasRole('super_admin');
  }
}
