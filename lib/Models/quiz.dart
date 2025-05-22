import 'package:admin_dashboard/Models/question.dart' show Question;

class Quiz {
  final String name;
  final int subjectId;
  final int? lessonId;
  final int grade;
  final String type;
  final int numberOfAttempts;
  final int timeLimit;
  final List<Question> content;

  Quiz({
    required this.name,
    required this.subjectId,
    this.lessonId,
    required this.grade,
    required this.type,
    required this.numberOfAttempts,
    required this.timeLimit,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'subjectId': subjectId,
    if (lessonId != null) 'lessonId': lessonId,
    'grade': grade,
    'type': type,
    'numberOfAttempts': numberOfAttempts,
    'timeLimit': timeLimit,
    'content': content.map((q) => q.toJson()).toList(),
  };
}

class QuizDetails {
  final int id;
  final String name;
  final String type;
  final int grade;
  final int numberOfAttempts;
  final int timeLimit;
  final Map<String, dynamic> subject;
  final Map<String, dynamic>? lesson;
  final List<Question> content;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuizDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.grade,
    required this.numberOfAttempts,
    required this.timeLimit,
    required this.subject,
    this.lesson,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizDetails.fromJson(Map<String, dynamic> json) {
    return QuizDetails(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      grade: json['grade'],
      numberOfAttempts: json['numberOfAttempts'],
      timeLimit: json['timeLimit'],
      subject: json['subject'],
      lesson: json['lesson'],
      content: (json['content'] as List<dynamic>)
          .map((q) => Question.fromJson(q))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class QuizGet {
  final int id;
  final String name;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> subject;
  final Map<String, dynamic>? lesson;
  final List<Map<String, dynamic>> weeks;

  QuizGet({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.subject,
    this.lesson,
    required this.weeks,
  });

  factory QuizGet.fromJson(Map<String, dynamic> json) {
    return QuizGet(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      subject: json['subject'],
      lesson: json['lesson'],
      weeks: List<Map<String, dynamic>>.from(json['weeks']),
    );
  }
}


