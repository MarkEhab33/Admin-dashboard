import 'package:admin_dashboard/Constants/globals.dart';
import 'package:admin_dashboard/Models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizGet {
  final int id;
  final String name;
  final String type;
  final bool? isRecord;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> subject;
  final Map<String, dynamic>? lesson;

  QuizGet({
    required this.id,
    required this.name,
    required this.type,
    this.isRecord,
    required this.createdAt,
    required this.updatedAt,
    required this.subject,
    this.lesson,
  });

  factory QuizGet.fromJson(Map<String, dynamic> json) {
    return QuizGet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      isRecord: json['isRecord'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      subject: json['subject'],
      lesson: json['lesson'],
    );
  }
}

class QuizProvider with ChangeNotifier {
  List<QuizGet> _quizzes = [];
  bool _isLoading = false;
  String _error = '';
  QuizDetails? _currentQuiz;
  QuizDetails? get currentQuiz => _currentQuiz;

  List<QuizGet> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String get error => _error;

  List<Map<String, dynamic>> _semestersList = [];

  List<Map<String, dynamic>> get semestersList => _semestersList;

  Future<void> createQuiz(Quiz quiz) async {
    try {
      final requestBody = json.encode(quiz.toJson());
      print('Request body: $requestBody'); // Add this line to debug

      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Response status: ${response.statusCode}'); // Add this line to debug
      print('Response body: ${response.body}'); // Add this line to debug

      if (response.statusCode != 201) {
        throw Exception('Failed to create quiz: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating quiz: $e');
    }
  }

  Future<void> fetchQuizzes({ int? subjectId, int? lessonId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      String url = '${Globals.baseUrl}/quiz';
      if ( subjectId != null || lessonId != null) {
        url += '?';
        if (subjectId != null) url += 'subjectId=$subjectId&';
        if (lessonId != null) url += 'lessonId=$lessonId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _quizzes = (data['data'] as List)
            .map((quiz) => QuizGet.fromJson(quiz))
            .toList();
        _error = '';
      } else {
        _error = 'Failed to load quizzes';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizById(int id) async {
    try {
      print("PROVIDER: Starting fetchQuizById for ID: $id");
      _isLoading = true;
      _error = '';
      notifyListeners();
      print("PROVIDER: Set loading state to true");

      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/quiz/$id'),
      );
      print("PROVIDER: API response received - Status: ${response.statusCode}");
      // print("PROVIDER: Response body: ${response.body.substring(0, min(100, response.body.length))}...");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("PROVIDER: JSON decoded successfully");
        _currentQuiz = QuizDetails.fromJson(data['data']);
        print("PROVIDER: Quiz details parsed - ID: ${_currentQuiz?.id}, Name: ${_currentQuiz?.name}");
        _error = '';
      } else {
        _error = 'Failed to load quiz details - Status code: ${response.statusCode}';
        print("PROVIDER: Error - $_error");
      }
    } catch (e) {
      _error = e.toString();
      print("PROVIDER ERROR: $_error");
      print("PROVIDER ERROR: Stack trace: ${StackTrace.current}");
    } finally {
      _isLoading = false;
      print("PROVIDER: Set loading state to false, notifying listeners");
      notifyListeners();
    }
  }

  Future<void> updateQuiz(int id, Quiz quiz) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final requestBody = json.encode(quiz.toJson());

      // Debug information
      print('Updating quiz with ID: $id');
      print('Request URL: ${Globals.baseUrl}/quiz/$id');
      print('Request body: $requestBody');

      // Add a small delay to ensure the request is processed properly
      await Future.delayed(Duration(milliseconds: 300));

      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/quiz/$id'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check for successful response (200 OK or 201 Created)
      if (response.statusCode != 200 && response.statusCode != 201) {
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          // If response body is not valid JSON
          print('Error parsing response: $e');
        }

        String errorMessage = errorData['message'] ?? 'Unknown error occurred';
        throw Exception('Failed to update quiz (${response.statusCode}): $errorMessage');
      }

      // Parse the response to get the updated quiz data
      final responseData = json.decode(response.body);
      if (responseData['data'] != null) {
        // Update the current quiz with the response data
        _currentQuiz = QuizDetails.fromJson(responseData['data']);
        print('Quiz updated successfully - ID: ${_currentQuiz?.id}, Name: ${_currentQuiz?.name}');
        print('Quiz subcategory: ${_currentQuiz?.subCategory?.name ?? 'None'}');

        // Update the quiz in the list if it exists
        if (_quizzes.any((q) => q.id == id)) {
          final index = _quizzes.indexWhere((q) => q.id == id);
          if (index != -1) {
            final existingQuiz = _quizzes[index];
            // Create a new QuizGet with updated fields from the response
            _quizzes[index] = QuizGet(
              id: _currentQuiz!.id,
              name: _currentQuiz!.name,
              type: _currentQuiz!.type,
              isRecord: _currentQuiz!.isRecord,
              createdAt: _currentQuiz!.createdAt,
              updatedAt: _currentQuiz!.updatedAt,
              subject: _currentQuiz!.subject,
              lesson: _currentQuiz!.lesson,
           
            );
          }
        }
      } else {
        // Fallback: refresh the quiz data if response doesn't contain updated data
        if (_currentQuiz != null && _currentQuiz!.id == id) {
          await fetchQuizById(id);
        }
      }

      // Add a small delay to ensure state is updated properly
      await Future.delayed(Duration(milliseconds: 300));

    } catch (e) {
      _error = e.toString();
      print('Error in updateQuiz: $e');
      throw Exception('Error updating quiz: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteQuiz(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/quiz/$id'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete quiz: ${response.body}');
      }

      // Remove the quiz from the local list
      _quizzes.removeWhere((quiz) => quiz.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Error deleting quiz: $e');
    }
  }

  Future<Map<String, dynamic>> addQuizRedo(int studentId, int quizId) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/quiz-answers/redo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentId': studentId,
          'quizId': quizId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Redo entry added successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add redo entry',
          'error': responseData['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding redo entry: $e',
        'error': 'Network Error',
      };
    }
  }
}



