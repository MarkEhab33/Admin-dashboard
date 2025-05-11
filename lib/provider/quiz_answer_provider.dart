import 'package:admin_dashboard/Constants/globals.dart';
import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizAnswerProvider with ChangeNotifier {
  List<QuizAnswer> _quizAnswers = [];
  QuizAnswer? _currentQuizAnswer;
  bool _isLoading = false;
  String _error = '';

  List<QuizAnswer> get quizAnswers => _quizAnswers;
  QuizAnswer? get currentQuizAnswer => _currentQuizAnswer;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch all quiz answers for a specific quiz
  Future<void> fetchQuizAnswersByQuizId(int quizId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Fetching quiz answers for quiz ID: $quizId');
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/quiz-answers/quiz/$quizId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');

        _quizAnswers = (data['data'] as List)
            .map((answer) => QuizAnswer.fromJson(answer))
            .toList();

        print('Parsed ${_quizAnswers.length} quiz answers');
        _error = '';
      } else {
        _error = 'Failed to load quiz answers: ${response.body}';
        print('Error: $_error');
      }
    } catch (e) {
      _error = 'Exception fetching quiz answers: $e';
      print('Exception: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a specific quiz answer by ID with combined question and answer data
  Future<void> fetchQuizAnswerById(int id) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Fetching quiz answer details for ID: $id');
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/quiz-answers/$id'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');

        _currentQuizAnswer = QuizAnswer.fromJson(data['data']);
        print('Parsed quiz answer with ID: ${_currentQuizAnswer?.id}');

        _error = '';
      } else {
        _error = 'Failed to load quiz answer details: ${response.body}';
        print('Error: $_error');
      }
    } catch (e) {
      _error = 'Exception fetching quiz answer: $e';
      print('Exception: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Grade a quiz answer
  Future<void> gradeQuizAnswer(int id, int grade) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Grading quiz answer ID: $id with grade: $grade');
      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/quiz-answers/$id/grade'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({'grade': grade}),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');

        _currentQuizAnswer = QuizAnswer.fromJson(data['data']);
        print('Updated quiz answer with grade: ${_currentQuizAnswer?.grade}');

        // Update the quiz answer in the list if it exists
        final index = _quizAnswers.indexWhere((answer) => answer.id == id);
        if (index != -1) {
          _quizAnswers[index] = _currentQuizAnswer!;
          print('Updated quiz answer in the list at index: $index');
        }

        _error = '';
      } else {
        _error = 'Failed to grade quiz answer: ${response.body}';
        print('Error: $_error');
      }
    } catch (e) {
      _error = 'Exception grading quiz answer: $e';
      print('Exception: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all quiz answers for a specific student
  Future<void> fetchQuizAnswersByStudentId(int studentId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Fetching quiz answers for student ID: $studentId');
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/quiz-answers/student/$studentId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');

        _quizAnswers = (data['data'] as List)
            .map((answer) => QuizAnswer.fromJson(answer))
            .toList();

        print('Parsed ${_quizAnswers.length} quiz answers for student');
        _error = '';
      } else {
        _error = 'Failed to load student quiz answers: ${response.body}';
        print('Error: $_error');
      }
    } catch (e) {
      _error = 'Exception fetching student quiz answers: $e';
      print('Exception: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear current quiz answer
  void clearCurrentQuizAnswer() {
    _currentQuizAnswer = null;
    notifyListeners();
  }
}
