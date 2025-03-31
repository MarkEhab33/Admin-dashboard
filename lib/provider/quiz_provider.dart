import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Constants/globals.dart';
import '../Models/quiz.dart';

class QuizProvider with ChangeNotifier {
  Future<void> createQuiz(Quiz quiz) async {
    try {
      final response = await http.post(
        Uri.parse('${Globals.baseUrl}/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(quiz.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create quiz: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating quiz: $e');
    }
  }
}