enum QuestionType { mcq, text, record }

class MCQAnswer {
  final int id;
  final String text;

  MCQAnswer({required this.id, required this.text});

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
  };
}

class Question {
  final String question;
  final QuestionType type;
  final double grade;
  final List<MCQAnswer>? answers;
  final int? correctAnswerId;
  final String? correctAnswer;
  final int? maxDuration;

  Question({
    required this.question,
    required this.type,
    required this.grade,
    this.answers,
    this.correctAnswerId,
    this.correctAnswer,
    this.maxDuration,
  }) {
    if (type == QuestionType.mcq && (answers == null || correctAnswerId == null)) {
      throw ArgumentError('MCQ questions must have answers and a correct answer');
    }
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'type': type.toString().split('.').last,
    'grade': grade,
    if (answers != null) 'answers': answers!.map((a) => a.toJson()).toList(),
    if (correctAnswerId != null) 'correctAnswerId': correctAnswerId,
    if (correctAnswer != null) 'correctAnswer': correctAnswer,
    if (maxDuration != null) 'maxDuration': maxDuration,
  };

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      grade: json['grade'].toDouble(),
      answers: json['answers'] != null
          ? (json['answers'] as List)
              .map((a) => MCQAnswer(id: a['id'], text: a['text']))
              .toList()
          : null,
      correctAnswerId: json['correctAnswerId'],
      correctAnswer: json['correctAnswer'],
      maxDuration: json['maxDuration'],
    );
  }
}

class Quiz {
  final String name;
  final int subjectId;
  final int semesterId;
  final int grade;
  final String type;
  final int numberOfAttempts;
  final int timeLimit;
  final List<Question> content;

  Quiz({
    required this.name,
    required this.subjectId,
    required this.semesterId,
    required this.grade,
    required this.type,
    required this.numberOfAttempts,
    required this.timeLimit,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'subjectId': subjectId,
    'semesterId': semesterId,
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
  final Map<String, dynamic> semester;
  final Map<String, dynamic> subject;
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
    required this.semester,
    required this.subject,
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
      semester: json['semester'],
      subject: json['subject'],
      content: (json['content'] as List<dynamic>)
          .map((q) => Question.fromJson(q))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

