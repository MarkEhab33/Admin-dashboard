import 'dart:convert';
import 'package:admin_dashboard/Models/student.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Constants/globals.dart';
import '../Models/Subject_Template.dart';
import '../Models/semester.dart';
import '../Models/subject.dart';
import '../Models/week.dart';

class SemestersProvider with ChangeNotifier {
  List<Semester> _semesters = [];
  bool _isLoading = false;
  String? _error;

  List<Semester> get semesters => _semesters;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSemesters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/semester/all'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> responseData = jsonResponse['data'] as List<dynamic>;
        
        if (responseData.isNotEmpty) {
          _semesters = responseData
              .map((semesterJson) => Semester.fromJson(semesterJson))
              .toList();
        } else {
          _semesters = [];
          _error = 'No semester data available';
          print(_error);
        }
      } else {
        _error = 'Failed to fetch semesters: ${response.statusCode}';
        print(_error);
      }
    } catch (e, stackTrace) {
      _error = 'Error fetching semesters: $e';
      print(_error);
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudentToSemester(String semesterId, String studentId) async {
    try {
      // Implement API call to add student to semester
      // Update the local semester data
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeStudentFromSemester(String semesterId, String studentId) async {
    try {
      // Implement API call to remove student from semester
      // Update the local semester data
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<List<Student>> searchAvailableStudents(String semesterId, String query) async {
    try {
      // Implement API call to search for students not in the semester
      // Return filtered list of students
      return [];
    } catch (e) {
      // Handle error
      return [];
    }
  }

  Future<Week?> addWeek(int semesterId, int weekNo, DateTime startDate, DateTime endDate) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/semester/$semesterId/week'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'weekNo': weekNo,
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final newWeek = Week.fromJson(jsonResponse['data']);
        
        // Update the local semester data
        final semesterIndex = _semesters.indexWhere((s) => s.id == semesterId);
        if (semesterIndex != -1) {
          _semesters[semesterIndex].weeks.add(newWeek);
          _semesters[semesterIndex].weeks.sort((a, b) => a.weekNo.compareTo(b.weekNo));
          notifyListeners();
        }
        
        return newWeek;
      } else {
        throw Exception('Failed to add week: ${response.body}');
      }
    } catch (e) {
      print('Error adding week: $e');
      throw Exception('Error adding week: $e');
    }
  }

  Future<Semester> fetchSemesterById(int semesterId) async {
    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/semester/$semesterId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final updatedSemester = Semester.fromJson(jsonResponse['data']);
        
        // Update the semester in the local list
        final index = _semesters.indexWhere((s) => s.id == semesterId);
        if (index != -1) {
          _semesters[index] = updatedSemester;
          notifyListeners();
        }
        
        return updatedSemester;
      } else {
        throw Exception('Failed to fetch semester: ${response.body}');
      }
    } catch (e) {
      print('Error fetching semester: $e');
      throw Exception('Error fetching semester: $e');
    }
  }

  Future<List<Lesson>> fetchWeekLessons(int weekId) async {
    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/semester/week/$weekId/lessons'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> lessonsData = jsonResponse['data'] as List<dynamic>;
        
        // Extract the lesson object from the nested structure
        return lessonsData.map((weekLesson) {
          final lessonData = weekLesson['lesson'] as Map<String, dynamic>;
          return Lesson.fromJson(lessonData);
        }).toList();
      } else {
        throw Exception('Failed to fetch lessons: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching week lessons: $e');
      throw Exception('Error fetching lessons: $e');
    }
  }

  Future<void> deleteLesson(int weekId, int lessonId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/semester/week/$weekId/lesson/$lessonId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete lesson: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting lesson: $e');
    }
  }

  Future<List<Subject>> fetchSemesterSubjects(int semesterId) async {
    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/semester/$semesterId/subjects'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> subjectsData = jsonResponse['data'] as List<dynamic>;
        return subjectsData.map((subjectJson) => Subject.fromJson(subjectJson)).toList();
      } else {
        throw Exception('Failed to fetch subjects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching subjects: $e');
    }
  }

  Future<List<Lesson>> fetchSubjectLessons(int subjectId) async {
    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/subject/$subjectId/lessons'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> lessonsData = jsonResponse['data'] as List<dynamic>;
        return lessonsData.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
      } else {
        throw Exception('Failed to fetch lessons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  Future<void> addLessonToWeek(
      {required int weekId, required int lessonId}) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/semester/week/$weekId/lesson'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'lessonId': lessonId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add lesson to week: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding lesson to week: $e');
    }
  }

  Future<void> addSemester({
    required int semesterTemplateId,
    required int year,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/semester'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'semesterTemplateId': semesterTemplateId,
          'year': year,
          'name': name,
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchSemesters(); // Refresh the semesters list
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create semester');
      }
    } catch (e) {
      throw Exception('Error creating semester: $e');
    }
  }
}




