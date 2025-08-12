import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Constants/globals.dart';

class PasswordResetService {
  static const String _endpoint = '/auth/reset-password';

  /// Reset a user's password using their email
  /// 
  /// [email] - The user's email address
  /// [newPassword] - The new password (must be at least 8 characters)
  /// 
  /// Returns a Map with success status and message
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}$_endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password reset successfully',
          'email': responseData['email'],
          'userId': responseData['userId'],
        };
      } else {
        // Handle different error status codes
        String errorMessage = 'Password reset failed';
        
        if (response.statusCode == 403) {
          errorMessage = responseData['message'] ?? 'User not found';
        } else if (response.statusCode == 400) {
          if (responseData['message'] is List) {
            errorMessage = (responseData['message'] as List).join(', ');
          } else {
            errorMessage = responseData['message'] ?? 'Invalid input data';
          }
        } else {
          errorMessage = responseData['message'] ?? 'Unknown error occurred';
        }

        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
        'statusCode': 0,
      };
    }
  }
}
