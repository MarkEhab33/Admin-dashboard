import 'package:admin_dashboard/Models/quiz.dart';

class StudentAnswer {
  final String type;
  final int questionId;
  final int? selectedAnswerId;
  final String? text;
  final String? recordingUrl;

  StudentAnswer({
    required this.type,
    required this.questionId,
    this.selectedAnswerId,
    this.text,
    this.recordingUrl,
  });

  factory StudentAnswer.fromJson(Map<String, dynamic> json) {
    return StudentAnswer(
      type: json['type'],
      questionId: json['questionId'],
      selectedAnswerId: json['selectedAnswerId'],
      text: json['text'],
      recordingUrl: json['recordingUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'questionId': questionId,
    };

    if (selectedAnswerId != null) data['selectedAnswerId'] = selectedAnswerId;
    if (text != null) data['text'] = text;
    if (recordingUrl != null) data['recordingUrl'] = recordingUrl;

    return data;
  }
}

class CombinedQuestionAnswer {
  final Question question;
  final StudentAnswer studentAnswer;

  CombinedQuestionAnswer({
    required this.question,
    required this.studentAnswer,
  });

  factory CombinedQuestionAnswer.fromJson(Map<String, dynamic> json) {
    return CombinedQuestionAnswer(
      question: Question.fromJson(json['question']),
      studentAnswer: StudentAnswer.fromJson(json['studentAnswer']),
    );
  }
}

class QuizAnswer {
  final int id;
  final int studentId;
  final int quizId;
  final List<StudentAnswer> answers;
  final int? grade;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? quiz;
  final Map<String, dynamic>? student;
  final List<CombinedQuestionAnswer>? combinedData;

  QuizAnswer({
    required this.id,
    required this.studentId,
    required this.quizId,
    required this.answers,
    this.grade,
    required this.createdAt,
    required this.updatedAt,
    this.quiz,
    this.student,
    this.combinedData,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    List<StudentAnswer> answersList = [];
    if (json['answers'] != null) {
      answersList = (json['answers'] as List)
          .map((answer) => StudentAnswer.fromJson(answer))
          .toList();
    }

    List<CombinedQuestionAnswer>? combinedDataList;
    if (json['combinedData'] != null) {
      combinedDataList = (json['combinedData'] as List)
          .map((data) => CombinedQuestionAnswer.fromJson(data))
          .toList();
    }

    return QuizAnswer(
      id: json['id'],
      studentId: json['studentId'],
      quizId: json['quizId'],
      answers: answersList,
      grade: json['grade'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      quiz: json['quiz'],
      student: json['student'],
      combinedData: combinedDataList,
    );
  }
}
