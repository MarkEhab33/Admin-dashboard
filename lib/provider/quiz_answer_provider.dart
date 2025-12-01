import 'package:admin_dashboard/Constants/globals.dart';
import 'package:admin_dashboard/Models/quiz_answer.dart';
import 'package:admin_dashboard/Models/quiz_answer_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizAnswerProvider with ChangeNotifier {
  List<QuizAnswerDetails> _quizAnswers = [];
  QuizAnswerDetails? _currentQuizAnswer;
  QuizAnswersList? _quizAnswersList;
  QuizAnswersSummary? _quizAnswersSummary;
  bool _isLoading = false;
  String _error = '';

  List<QuizAnswerDetails> get quizAnswers => _quizAnswers;
  QuizAnswerDetails? get currentQuizAnswer => _currentQuizAnswer;
  QuizAnswersList? get quizAnswersList => _quizAnswersList;
  QuizAnswersSummary? get quizAnswersSummary => _quizAnswersSummary;
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

  // Delete a quiz answer by ID
  Future<void> deleteQuizAnswer(int id) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Deleting quiz answer ID: $id');
      final response = await http.delete(
        Uri.parse('${Globals.baseUrl}/quiz-answers/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Delete response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Quiz answer deleted successfully: ${data['message']}');

        // Remove the deleted answer from local lists if they exist
        if (_quizAnswersList != null) {
          _quizAnswersList!.answers.removeWhere((answer) => answer.id == id);
        }

        // Clear current quiz answer if it's the one being deleted
        if (_currentQuizAnswer?.id == id) {
          _currentQuizAnswer = null;
        }

        _error = '';
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to delete quiz answer';
        print('Error deleting quiz answer: $_error');
        throw Exception(_error);
      }
    } catch (e) {
      _error = 'Exception deleting quiz answer: $e';
      print('Exception: $_error');
      throw Exception(_error);
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
        print(data['data']);
        if (_currentQuizAnswer != null) {
          // Create a new QuizAnswerDetails with the updated grade but keeping all other properties
          _currentQuizAnswer = QuizAnswerDetails(
            id: _currentQuizAnswer!.id,
            quizId: _currentQuizAnswer!.quizId,
            quizName: _currentQuizAnswer!.quizName,
            quizType: _currentQuizAnswer!.quizType,
            studentId: _currentQuizAnswer!.studentId,
            studentName: _currentQuizAnswer!.studentName,
            studentCode: _currentQuizAnswer!.studentCode,
            studentEmail: _currentQuizAnswer!.studentEmail,
            semesterId: _currentQuizAnswer!.semesterId,
            semesterName: _currentQuizAnswer!.semesterName,
            lessonId: _currentQuizAnswer!.lessonId,
            lessonName: _currentQuizAnswer!.lessonName,
            weekId: _currentQuizAnswer!.weekId,
            weekNumber: _currentQuizAnswer!.weekNumber,
            subjectId: _currentQuizAnswer!.subjectId,
            subjectName: _currentQuizAnswer!.subjectName,
            timeTaken: _currentQuizAnswer!.timeTaken,
            timeLimit: _currentQuizAnswer!.timeLimit,
            attemptNumber: _currentQuizAnswer!.attemptNumber,
            maxAttempts: _currentQuizAnswer!.maxAttempts,
            submissionDate: _currentQuizAnswer!.submissionDate,
            autoGraded: _currentQuizAnswer!.autoGraded,
            grade: data['data']['grade'], // Update only the grade
            finalGrade: _currentQuizAnswer!.finalGrade,
            answers: _currentQuizAnswer!.answers,
          );
        }

        // Update the quiz answer in the list if it exists
        // final index = _quizAnswers.indexWhere((answer) => answer.id == id);
        // if (index != -1) {
        //   _quizAnswers[index] = _currentQuizAnswer!;
        //   print('Updated quiz answer in the list at index: $index');
        // }

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
            .map((answer) => QuizAnswerDetails.fromJson(answer))
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

  // Fetch quiz answers summary using the new endpoint
  Future<void> fetchQuizAnswersSummary({ int? quizId, int? lessonId, int? subjectId, int? weekId, int? semesterId,}) async {
      try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Build query parameters
      final Map<String, String> queryParams = {};
      if (quizId != null) queryParams['quizId'] = quizId.toString();
      if (lessonId != null) queryParams['lessonId'] = lessonId.toString();
      if (subjectId != null) queryParams['subjectId'] = subjectId.toString();
      if (weekId != null) queryParams['weekId'] = weekId.toString();
      if (semesterId != null) queryParams['semesterId'] = semesterId.toString();

      final uri = Uri.parse('${Globals.baseUrl}/quiz-answers/summary')
          .replace(queryParameters: queryParams);

      debugPrint('Fetching quiz answers summary from: $uri');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Received data: ${data['message']}');

        _quizAnswersSummary = QuizAnswersSummary.fromJson(data);
        _error = '';
      } else {
        _error = 'Failed to load quiz answers summary: ${response.body}';
        debugPrint('Error: $_error');
      }
    } catch (e) {
      _error = 'Exception fetching quiz answers summary: $e';
      debugPrint('Exception: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  // Clear quiz answers summary
  void clearQuizAnswersSummary() {
    _quizAnswersSummary = null;
    notifyListeners();
  }

  // Fetch a quiz answer with its questions


  // Grade a quiz answer with question-specific grades
  Future<bool> gradeQuizAnswerWithQuestions(int quizAnswerId, int totalGrade) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      print('Grading quiz answer ID: $quizAnswerId with grade: $totalGrade');


      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/quiz-answers/$quizAnswerId/grade'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'grade': totalGrade,
        }),
      );

      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Received data: ${data['message']}');
        if (_currentQuizAnswer != null) {
          // Create a new QuizAnswerDetails with the updated grade but keeping all other properties
          _currentQuizAnswer = QuizAnswerDetails(
            id: _currentQuizAnswer!.id,
            quizId: _currentQuizAnswer!.quizId,
            quizName: _currentQuizAnswer!.quizName,
            quizType: _currentQuizAnswer!.quizType,
            studentId: _currentQuizAnswer!.studentId,
            studentName: _currentQuizAnswer!.studentName,
            studentCode: _currentQuizAnswer!.studentCode,
            studentEmail: _currentQuizAnswer!.studentEmail,
            semesterId: _currentQuizAnswer!.semesterId,
            semesterName: _currentQuizAnswer!.semesterName,
            lessonId: _currentQuizAnswer!.lessonId,
            lessonName: _currentQuizAnswer!.lessonName,
            weekId: _currentQuizAnswer!.weekId,
            weekNumber: _currentQuizAnswer!.weekNumber,
            subjectId: _currentQuizAnswer!.subjectId,
            subjectName: _currentQuizAnswer!.subjectName,
            timeTaken: _currentQuizAnswer!.timeTaken,
            timeLimit: _currentQuizAnswer!.timeLimit,
            attemptNumber: _currentQuizAnswer!.attemptNumber,
            maxAttempts: _currentQuizAnswer!.maxAttempts,
            submissionDate: _currentQuizAnswer!.submissionDate,
            autoGraded: _currentQuizAnswer!.autoGraded,
            grade: data['data']['grade'], // Update only the grade
            finalGrade: _currentQuizAnswer!.finalGrade,
            answers: _currentQuizAnswer!.answers,
          );
        }
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

  Future<void> fetchQuizAnswerDetails(int quizAnswerId) async {
    print('=== PROVIDER: fetchQuizAnswerDetails ===');
    print('PROVIDER: Quiz Answer ID: $quizAnswerId');

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final url = '${Globals.baseUrl}/quiz-answers/$quizAnswerId';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('PROVIDER: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);

          if (responseData['data'] != null) {
            _currentQuizAnswer = QuizAnswerDetails.fromJson(responseData['data']);
            print('PROVIDER: Successfully loaded quiz answer details');
            print('PROVIDER: Quiz: ${_currentQuizAnswer?.quizName}');
            print('PROVIDER: Answers count: ${_currentQuizAnswer?.answers.length}');

            _isLoading = false;
            notifyListeners();
          } else {
            _error = 'No data field in response';
            _isLoading = false;
            notifyListeners();
          }
        } catch (jsonError) {
          print('PROVIDER: JSON parsing error: $jsonError');
          _error = 'Error parsing response: $jsonError';
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _error = 'Failed to load quiz answer details - Status: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('PROVIDER: Network error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
