import 'package:admin_dashboard/Constants/globals.dart';
import 'package:admin_dashboard/Models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizGet {
  final int id;
  final String name;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> semester;
  final Map<String, dynamic> subject;

  QuizGet({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.semester,
    required this.subject,
  });

  factory QuizGet.fromJson(Map<String, dynamic> json) {
    return QuizGet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      semester: json['semester'],
      subject: json['subject'],
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

  Future<void> fetchQuizzes({int? semesterId, int? subjectId}) async {
    try {
      _isLoading = true;
      notifyListeners();

      String url = '${Globals.baseUrl}/quiz';
      if (semesterId != null || subjectId != null) {
        url += '?';
        if (semesterId != null) url += 'semesterId=$semesterId&';
        if (subjectId != null) url += 'subjectId=$subjectId';
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
      _isLoading = true;
      _error = '';
      notifyListeners();

      final response = await http.get(
        Uri.parse('${Globals.baseUrl}/quiz/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentQuiz = QuizDetails.fromJson(data['data']);
        _error = '';
      } else {
        _error = 'Failed to load quiz details';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuiz(int id, Quiz quiz) async {
    try {
      final requestBody = json.encode(quiz.toJson());
      final response = await http.put(
        Uri.parse('${Globals.baseUrl}/quiz/$id'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update quiz: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating quiz: $e');
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
}





