import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_auth_service.dart';

class AuthenticatedHttpClient {
  static final AuthenticatedHttpClient _instance = AuthenticatedHttpClient._internal();
  factory AuthenticatedHttpClient() => _instance;
  AuthenticatedHttpClient._internal();

  final AdminAuthService _authService = AdminAuthService();
  final http.Client _client = http.Client();

  // GET request with authentication
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool requireAuth = true,
  }) async {
    final authHeaders = await _getAuthHeaders(requireAuth);
    final finalHeaders = {...?headers, ...authHeaders};
    
    print('=== AUTHENTICATED GET ===');
    print('URL: $url');
    print('Headers: $finalHeaders');
    
    try {
      final response = await _client.get(url, headers: finalHeaders);
      return await _handleResponse(response, () => get(url, headers: headers, requireAuth: requireAuth));
    } catch (e) {
      print('GET request error: $e');
      rethrow;
    }
  }

  // POST request with authentication
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    final authHeaders = await _getAuthHeaders(requireAuth);
    final finalHeaders = {...?headers, ...authHeaders};
    
    print('=== AUTHENTICATED POST ===');
    print('URL: $url');
    print('Headers: $finalHeaders');
    print('Body: $body');
    
    try {
      final response = await _client.post(
        url,
        headers: finalHeaders,
        body: body,
        encoding: encoding,
      );
      return await _handleResponse(
        response,
        () => post(url, headers: headers, body: body, encoding: encoding, requireAuth: requireAuth),
      );
    } catch (e) {
      print('POST request error: $e');
      rethrow;
    }
  }

  // PUT request with authentication
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    final authHeaders = await _getAuthHeaders(requireAuth);
    final finalHeaders = {...?headers, ...authHeaders};
    
    print('=== AUTHENTICATED PUT ===');
    print('URL: $url');
    print('Headers: $finalHeaders');
    
    try {
      final response = await _client.put(
        url,
        headers: finalHeaders,
        body: body,
        encoding: encoding,
      );
      return await _handleResponse(
        response,
        () => put(url, headers: headers, body: body, encoding: encoding, requireAuth: requireAuth),
      );
    } catch (e) {
      print('PUT request error: $e');
      rethrow;
    }
  }

  // DELETE request with authentication
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    bool requireAuth = true,
  }) async {
    final authHeaders = await _getAuthHeaders(requireAuth);
    final finalHeaders = {...?headers, ...authHeaders};
    
    print('=== AUTHENTICATED DELETE ===');
    print('URL: $url');
    print('Headers: $finalHeaders');
    
    try {
      final response = await _client.delete(
        url,
        headers: finalHeaders,
        body: body,
        encoding: encoding,
      );
      return await _handleResponse(
        response,
        () => delete(url, headers: headers, body: body, encoding: encoding, requireAuth: requireAuth),
      );
    } catch (e) {
      print('DELETE request error: $e');
      rethrow;
    }
  }

  // Get authentication headers
  Future<Map<String, String>> _getAuthHeaders(bool requireAuth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requireAuth) {
      final accessToken = _authService.getAccessToken();
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
        print('Added auth header: Bearer ${accessToken.substring(0, 20)}...');
      } else {
        print('Warning: No access token available for authenticated request');
      }
    }

    return headers;
  }

  // Handle response and automatic token refresh
  Future<http.Response> _handleResponse(
    http.Response response,
    Future<http.Response> Function() retryRequest,
  ) async {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // If unauthorized, try to refresh token and retry
    if (response.statusCode == 401) {
      print('Received 401, attempting token refresh...');
      
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        print('Token refreshed successfully, retrying request...');
        return await retryRequest();
      } else {
        print('Token refresh failed, request will fail with 401');
      }
    }

    return response;
  }

  // Close the client
  void close() {
    _client.close();
  }
}

// Convenience methods for common use cases
class ApiClient {
  static final AuthenticatedHttpClient _httpClient = AuthenticatedHttpClient();

  // GET with automatic JSON parsing
  static Future<Map<String, dynamic>> getJson(String url) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // POST with automatic JSON parsing
  static Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> data) async {
    final response = await _httpClient.post(
      Uri.parse(url),
      body: json.encode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Request failed: ${response.statusCode}');
    }
  }

  // PUT with automatic JSON parsing
  static Future<Map<String, dynamic>> putJson(String url, Map<String, dynamic> data) async {
    final response = await _httpClient.put(
      Uri.parse(url),
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Request failed: ${response.statusCode}');
    }
  }

  // DELETE with automatic JSON parsing
  static Future<Map<String, dynamic>> deleteJson(String url) async {
    final response = await _httpClient.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Request failed: ${response.statusCode}');
    }
  }
}
