import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../Constants/globals.dart';

class AdminAuthService {
  static const String _accessTokenKey = 'admin_access_token';
  static const String _refreshTokenKey = 'admin_refresh_token';
  static const String _adminDataKey = 'admin_data';

  // Get stored access token
  String? getAccessToken() {
    try {
      return html.window.localStorage[_accessTokenKey];
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  // Get stored refresh token
  String? getRefreshToken() {
    try {
      return html.window.localStorage[_refreshTokenKey];
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  // Get stored admin data
  Map<String, dynamic>? getAdminData() {
    try {
      final adminDataString = html.window.localStorage[_adminDataKey];
      if (adminDataString != null) {
        return json.decode(adminDataString);
      }
      return null;
    } catch (e) {
      print('Error getting admin data: $e');
      return null;
    }
  }

  // Store tokens and admin data
  void _storeAuthData({
    required String accessToken,
    required String refreshToken,
    Map<String, dynamic>? adminData,
  }) {
    try {
      print('=== STORING AUTH DATA ===');
      print('Access token: ${accessToken.substring(0, 20)}...');
      print('Refresh token: ${refreshToken.substring(0, 20)}...');
      
      html.window.localStorage[_accessTokenKey] = accessToken;
      html.window.localStorage[_refreshTokenKey] = refreshToken;
      
      if (adminData != null) {
        html.window.localStorage[_adminDataKey] = json.encode(adminData);
        print('Admin data stored: ${adminData['username']}');
      }
    } catch (e) {
      print('Error storing auth data: $e');
      throw Exception('Failed to store authentication data');
    }
  }

  // Clear all stored auth data
  void clearAuthData() {
    try {
      print('=== CLEARING AUTH DATA ===');
      html.window.localStorage.remove(_accessTokenKey);
      html.window.localStorage.remove(_refreshTokenKey);
      html.window.localStorage.remove(_adminDataKey);
      print('Auth data cleared successfully');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  // Check if admin is authenticated
  bool isAuthenticated() {
    final accessToken = getAccessToken();
    final refreshToken = getRefreshToken();
    final isAuth = accessToken != null && refreshToken != null;
    print('=== AUTH CHECK ===');
    print('Access token exists: ${accessToken != null}');
    print('Refresh token exists: ${refreshToken != null}');
    print('Is authenticated: $isAuth');
    return isAuth;
  }

  // Login admin
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('=== ADMIN LOGIN ATTEMPT ===');
      print('Username: $username');
      print('Login URL: ${Globals.baseUrl}/admin/auth/login');

      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/admin/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Store tokens
        _storeAuthData(
          accessToken: responseData['access_token'],
          refreshToken: responseData['refresh_token'],
        );

        // Get admin info
        try {
          final adminInfo = await getAdminInfo();
          print('Admin info retrieved successfully: $adminInfo');

          return {
            'success': true,
            'message': 'Login successful',
            'admin': adminInfo,
          };
        } catch (adminInfoError) {
          print('Failed to get admin info: $adminInfoError');
          // Return fallback admin data if API fails
          final fallbackAdminData = {
            'id': 1,
            'username': username,
            'name': 'Aripsalin Administrator',
            'role': 'super_admin',
            'isActive': true,
            'createdAt': DateTime.now().toIso8601String(),
          };

          return {
            'success': true,
            'message': 'Login successful (using fallback admin data)',
            'admin': fallbackAdminData,
          };
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Get admin info
  Future<Map<String, dynamic>> getAdminInfo() async {
    try {
      final accessToken = getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      print('=== GETTING ADMIN INFO ===');
      print('URL: ${Globals.baseUrl}/admin/auth/me');

      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/admin/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Admin info response status: ${response.statusCode}');
      print('Admin info response body: ${response.body}');

      if (response.statusCode == 200) {
        final adminData = json.decode(response.body);
        
        // Store admin data
        html.window.localStorage[_adminDataKey] = json.encode(adminData);
        
        return adminData;
      } else if (response.statusCode == 401) {
        // Token expired, try to refresh
        print('Access token expired, attempting refresh...');
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry getting admin info
          return await getAdminInfo();
        } else {
          throw Exception('Session expired. Please login again.');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get admin info');
      }
    } catch (e) {
      print('Get admin info error: $e');
      throw Exception('Failed to get admin info: $e');
    }
  }

  // Refresh access token
  Future<bool> refreshToken() async {
    try {
      final refreshTokenValue = getRefreshToken();
      if (refreshTokenValue == null) {
        print('No refresh token available');
        return false;
      }

      print('=== REFRESHING TOKEN ===');
      print('URL: ${Globals.baseUrl}/admin/auth/refresh');

      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/admin/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshTokenValue',
          'Content-Type': 'application/json',
        },
      );

      print('Refresh token response status: ${response.statusCode}');
      print('Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Store new tokens
        _storeAuthData(
          accessToken: responseData['access_token'],
          refreshToken: responseData['refresh_token'],
        );
        
        print('Token refreshed successfully');
        return true;
      } else {
        print('Token refresh failed');
        clearAuthData();
        return false;
      }
    } catch (e) {
      print('Refresh token error: $e');
      clearAuthData();
      return false;
    }
  }

  // Logout admin
  Future<void> logout() async {
    try {
      final accessToken = getAccessToken();
      
      print('=== ADMIN LOGOUT ===');
      
      if (accessToken != null) {
        print('URL: ${Globals.baseUrl}/admin/auth/logout');
        
        final response = await http.post(
          Uri.parse('${Globals.baseUrl}/admin/auth/logout'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
        
        print('Logout response status: ${response.statusCode}');
      }
      
      // Clear local storage regardless of API response
      clearAuthData();
      print('Logout completed');
    } catch (e) {
      print('Logout error: $e');
      // Still clear local data even if API call fails
      clearAuthData();
    }
  }

  // Validate current session
  Future<bool> validateSession() async {
    try {
      if (!isAuthenticated()) {
        return false;
      }

      // Try to get admin info to validate token
      await getAdminInfo();
      return true;
    } catch (e) {
      print('Session validation failed: $e');
      clearAuthData();
      return false;
    }
  }
}
