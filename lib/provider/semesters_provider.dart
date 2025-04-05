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
      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/semester/add-user'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': int.parse(studentId),
          'semesterId': int.parse(semesterId),
          'role': 'student'
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add student: ${response.body}');
      }

      // Refresh the semester data to get the updated student list
      await fetchSemesters();
      notifyListeners();
    } catch (e) {
      print('Error adding student to semester: $e');
      throw Exception('Failed to add student: $e');
    }
  }

  Future<void> removeStudentFromSemester(String semesterId, String studentId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/semester/remove-user'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': int.parse(studentId),
          'semesterId': int.parse(semesterId),
          'role': 'student'
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove student: ${response.body}');
      }

      // Refresh the semester data to get the updated student list
      await fetchSemesters();
      notifyListeners();
    } catch (e) {
      print('Error removing student from semester: $e');
      throw Exception('Failed to remove student: $e');
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
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final semesterData = jsonResponse['data'];
        return Semester.fromJson(semesterData);
      } else {
        throw Exception('Failed to fetch semester: ${response.statusCode}');
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

  Future<List<Map<String, dynamic>>> fetchWeekQuizzes(int weekId) async {
    try {
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/quiz/week/$weekId/simple'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to fetch quizzes');
      }
    } catch (e) {
      throw Exception('Error fetching quizzes: $e');
    }
  }

  Future<void> addQuizToWeek({required int weekId, required int quizId}) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/quiz/week/$weekId/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'quizId': quizId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add quiz to week: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding quiz to week: $e');
    }
  }

  Future<void> removeQuizFromWeek(int weekId, int quizId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/quiz/week/$weekId/quiz/$quizId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove quiz from week');
      }
    } catch (e) {
      throw Exception('Error removing quiz from week: $e');
    }
  }
  Future<Week> updateWeek({
    required int weekId,
    required int weekNo,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/semester/week/$weekId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'weekNo': weekNo,
          'startDate': startDate.toUtc().toIso8601String(),
          'endDate': endDate.toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final updatedWeek = Week.fromJson(jsonResponse['data']);

        // Update the week in the local state
        for (var semester in _semesters) {
          final weekIndex = semester.weeks.indexWhere((w) => w.id == weekId);
          if (weekIndex != -1) {
            semester.weeks[weekIndex] = updatedWeek;
            semester.weeks.sort((a, b) => a.weekNo.compareTo(b.weekNo));
            notifyListeners();
            break;
          }
        }

        return updatedWeek;
      } else {
        throw Exception('Failed to update week: ${response.body}');
      }
    } catch (e) {
      print('Error updating week: $e');
      throw Exception('Error updating week: $e');
    }
  }
}





