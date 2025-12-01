import 'package:admin_dashboard/Constants/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/student.dart';
import '../Models/student_summary.dart';


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
        Uri.parse(Globals.getApiUrl('/user/students?isVerified=${isVerified ?? false}')),
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

  Future<void> fetchStudentsSummary() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(Globals.getApiUrl('/user/students/summary')),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Raw response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('Decoded response data: $responseData');

        if (responseData['data'] != null) {
          final List<dynamic> studentsData = responseData['data'] as List;
          
          if (studentsData.isNotEmpty) {
            print('First student data: ${studentsData.first}');
          }

          _students = studentsData.map((studentJson) {
            try {
              return Student.fromSummaryJson(studentJson as Map<String, dynamic>);
            } catch (e) {
              print('Error parsing student JSON: $e');
              print('Problematic student data: $studentJson');
              return null;
            }
          }).whereType<Student>().toList();
        } else {
          _students = [];
        }
      } else {
        _error = 'Failed to fetch students summary: ${response.statusCode}';
      }
    } catch (e) {
      print('Error details: $e');
      _error = 'Error fetching students summary: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<StudentSummary?> fetchStudentSummaryGrades(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/grades/student/$studentId/summary'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          return StudentSummary.fromJson(responseData['data']);
        }
      } else {
        throw Exception('Failed to fetch student summary grades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching student summary grades: $e');
    }
    return null;
  }

  /// Update student profile with user and student data including documents
  Future<Student> updateStudentProfile(int userId, Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/user/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(profileData),
      );

      print('Update profile response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final updatedStudent = Student.fromJson(responseData['data']);

          // Update the student in the local list
          final index = _students.indexWhere((s) => s.id == updatedStudent.id);
          if (index != -1) {
            _students[index] = updatedStudent;
            notifyListeners();
          }

          return updatedStudent;
        } else {
          throw Exception('No data returned from server');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating student profile: $e');
      throw Exception('Error updating student profile: $e');
    }
  }

  /// Update profile picture URL
  Future<void> updateProfilePicture(int userId, String profilePictureUrl) async {
    try {
      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/user/profile-picture/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'profilePicture': profilePictureUrl,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile picture');
      }
    } catch (e) {
      throw Exception('Error updating profile picture: $e');
    }
  }
}
