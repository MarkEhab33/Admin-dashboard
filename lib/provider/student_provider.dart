import 'package:admin_dashboard/Constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/student.dart';

class StudentsProvider with ChangeNotifier {
  List<Student> _students = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  List<Student> get filteredStudents {
    return _students.where((student) {
      final searchLower = _searchQuery.toLowerCase();
      return student.user.name.toLowerCase().contains(searchLower) ||
             student.studentCode.toLowerCase().contains(searchLower);
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchStudents({bool? isVerified}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://aripsalin-api-production.up.railway.app/user/students?isVerified=${isVerified ?? false}'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required authentication headers here
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          _students = (responseData['data'] as List)
              .map((studentJson) => Student.fromJson(studentJson))
              .toList();
        }
      } else {
        _error = 'Failed to fetch students: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching students: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyStudent(int studentId, String action) async {
    try {
      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/user/student/$studentId/verify'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': action,
        }),
      );

      if (response.statusCode == 200) {
    
        
        // Remove the student from the list
        _students.removeWhere((student) => student.id == studentId);
        notifyListeners();
        
        return true;
      } else {
        throw Exception('Failed to ${action} student: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ${action}ing student: $e');
    }
  }
}
