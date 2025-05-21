import 'package:admin_dashboard/Constants/globals.dart';
import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizAnswerProvider with ChangeNotifier {
  List<QuizAnswer> _quizAnswers = [];
  QuizAnswer? _currentQuizAnswer;
  QuizAnswersList? _quizAnswersList;
  bool _isLoading = false;
  String _error = '';

  List<QuizAnswer> get quizAnswers => _quizAnswers;
  QuizAnswer? get currentQuizAnswer => _currentQuizAnswer;
  QuizAnswersList? get quizAnswersList => _quizAnswersList;
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
        },
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');

        if (data['data'] != null) {
          // Create a QuizAnswersList directly from the API response
          final apiData = data['data'] as Map<String, dynamic>;

          // Extract the answers list
          final List<dynamic> answersJson = apiData['answers'] ?? [];

          // Create QuizAnswerSummary objects from each answer
          final List<QuizAnswerSummary> answers = answersJson.map((answer) {
            return QuizAnswerSummary(
              id: answer['id'] ?? 0,
              studentName: answer['studentName'] ?? '',
              studentCode: answer['studentCode'] ?? '',
              attemptNumber: answer['attemptNumber'] ?? 0,
              submissionDate: answer['submissionDate'] != null
                  ? DateTime.parse(answer['submissionDate'])
                  : DateTime.now(),
              grade: answer['grade'],
            );
          }).toList();

          // Create the QuizAnswersList object
          _quizAnswersList = QuizAnswersList(
            quizId: apiData['quizId'] ?? 0,
            quizName: apiData['quizName'] ?? '',
            totalSubmissions: apiData['totalSubmissions'] ?? 0,
            answers: answers,
          );

          print('Created QuizAnswersList with ${answers.length} answers');
          _error = '';
        } else {
          print('Data is null in the response');
          _error = 'Invalid response format: data is null';
        }
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

  // Fetch quiz answers list for a specific quiz
  Future<void> fetchQuizAnswersList(int quizId) async {
    // This method now just calls fetchQuizAnswersByQuizId for consistency
    await fetchQuizAnswersByQuizId(quizId);
  }

  // Clear quiz answers list
  void clearQuizAnswersList() {
    _quizAnswersList = null;
    notifyListeners();
  }

  // Fetch a quiz answer with its questions
  Future<Map<String, dynamic>?> fetchQuizAnswerWithQuestions(int quizAnswerId, int quizId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Fetching quiz answer details for ID: $quizAnswerId and quiz ID: $quizId');
      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/quiz-answers/$quizAnswerId/quiz/$quizId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');
        return data['data'];
      } else {
        _error = 'Failed to load quiz answer details: ${response.body}';
        print('Error: $_error');
        return null;
      }
    } catch (e) {
      _error = 'Exception fetching quiz answer details: $e';
      print('Exception: $_error');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Grade a quiz answer with question-specific grades
  Future<bool> gradeQuizAnswerWithQuestions(
    int quizAnswerId,
    int totalGrade,
    List<Map<String, dynamic>> questionGrades
  ) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Grading quiz answer ID: $quizAnswerId with grade: $totalGrade');
      print('Question grades: $questionGrades');

      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/quiz-answers/$quizAnswerId/grade'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'grade': totalGrade,
          'questionGrades': questionGrades,
        }),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');
        return true;
      } else {
        _error = 'Failed to grade quiz answer: ${response.body}';
        print('Error: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Exception grading quiz answer: $e';
      print('Exception: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
