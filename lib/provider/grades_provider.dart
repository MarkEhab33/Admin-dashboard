import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Constants/globals.dart';
import '../Models/grade_data.dart';
import '../Models/student.dart';
import '../Models/semester.dart';



class GradesProvider with ChangeNotifier {
  GradeData? _semesterGrades;
  bool _isLoading = false;
  String? _error;

  GradeData? get semesterGrades => _semesterGrades;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStudentSemesterGrades(int semesterId, int studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/grades/semester/$semesterId/student/$studentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'];
        
        _semesterGrades = GradeData.fromJson(data);
      } else {
        _error = 'Failed to fetch grades: ${response.statusCode}';
        print(_error);
      }
    } catch (e) {
      _error = 'Error fetching grades: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearGrades() {
    _semesterGrades = null;
    _error = null;
    notifyListeners();
  }
}