import 'package:admin_dashboard/Models/quiz_grade.dart';

class SubjectGrades {
  final int id;
  final String name;
  final String code;
  final List<QuizGrade> quizzes;

  SubjectGrades({
    required this.id,
    required this.name,
    required this.code,
    required this.quizzes,
  });

  factory SubjectGrades.fromJson(Map<String, dynamic> json) {
    return SubjectGrades(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      quizzes: (json['quizzes'] as List)
          .map((quiz) => QuizGrade.fromJson(quiz))
          .toList(),
    );
  }
}