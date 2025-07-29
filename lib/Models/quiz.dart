import 'package:admin_dashboard/Models/question.dart' show Question;
import 'package:admin_dashboard/Models/Subject_Template.dart' show SubCategory;

class Quiz {
  final String name;
  final int subjectId;
  final int? lessonId;
  final int grade;
  final String type;
  final int numberOfAttempts;
  final int? timeLimit;
  final bool? isRecord;
  final SubCategory? subCategory;
  final List<Question> content;
  final int easyQuestions;
  final int mediumQuestions;
  final int hardQuestions;

  Quiz({
    required this.name,
    required this.subjectId,
    this.lessonId,
    this.isRecord,
    required this.grade,
    required this.type,
    required this.numberOfAttempts,
     this.timeLimit,
    this.subCategory,
    required this.content,
    required this.easyQuestions,
    required this.mediumQuestions,
    required this.hardQuestions,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'subjectId': subjectId,
    if (lessonId != null) 'lessonId': lessonId,
    if (isRecord != null) 'isRecord': isRecord,
    'grade': grade,
    'type': type,
    'numberOfAttempts': numberOfAttempts,
    if (timeLimit != null) 'timeLimit': timeLimit,
    if (subCategory != null) 'subCategory': subCategory!.toJson(),
    'content': content.map((q) => q.toJson()).toList(),
    'easyQuestions': easyQuestions,
    'mediumQuestions': mediumQuestions,
    'hardQuestions': hardQuestions,
  };
}

class QuizDetails {
  final int id;
  final String name;
  final String type;
  final int grade;
  final int numberOfAttempts;
  final int? timeLimit;
  final bool? isRecord;
  final Map<String, dynamic> subject;
  final Map<String, dynamic>? lesson;
  final SubCategory? subCategory;
  final List<Question> content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int easyQuestions;
  final int mediumQuestions;
  final int hardQuestions;

  QuizDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.grade,
    required this.numberOfAttempts,
    this.timeLimit,
    required this.subject,
    this.lesson,
    this.isRecord,
    this.subCategory,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.easyQuestions,
    required this.mediumQuestions,
    required this.hardQuestions,
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
      isRecord: json['isRecord'],
      subCategory: json['subCategory'] != null
          ? SubCategory.fromJson(json['subCategory'])
          : null,
      content: (json['content'] as List<dynamic>)
          .map((q) => Question.fromJson(q))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      easyQuestions: json['easyQuestions'] ?? 0,
      mediumQuestions: json['mediumQuestions'] ?? 0,
      hardQuestions: json['hardQuestions'] ?? 0,
    );
  }
}

class QuizGet {
  final int id;
  final String name;
  final String type;
  final bool? isRecord;
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
    this.isRecord,
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
      isRecord: json['isRecord'],
      lesson: json['lesson'],
      weeks: List<Map<String, dynamic>>.from(json['weeks']),
    );
  }
}


