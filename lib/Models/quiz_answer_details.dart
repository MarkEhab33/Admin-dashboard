class QuizAnswerDetails {
  final int id;
  final int quizId;
  final String quizName;
  final String quizType;
  final int studentId;
  final String studentName;
  final String studentCode;
  final String studentEmail;
  final int semesterId;
  final String semesterName;
  final int lessonId;
  final String lessonName;
  final int weekId;
  final int weekNumber;
  final int subjectId;
  final String subjectName;
  final int timeTaken;
  final int timeLimit;
  final int attemptNumber;
  final int maxAttempts;
  final DateTime submissionDate;
  final bool autoGraded;
  final int? grade;
  final int finalGrade;
  final List<QuizAnswerItem> answers;

  QuizAnswerDetails({
    required this.id,
    required this.quizId,
    required this.quizName,
    required this.quizType,
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.studentEmail,
    required this.semesterId,
    required this.semesterName,
    required this.lessonId,
    required this.lessonName,
    required this.weekId,
    required this.weekNumber,
    required this.subjectId,
    required this.subjectName,
    required this.timeTaken,
    required this.timeLimit,
    required this.attemptNumber,
    required this.maxAttempts,
    required this.submissionDate,
    required this.autoGraded,
    this.grade,
    required this.finalGrade,
    required this.answers,
  });

  factory QuizAnswerDetails.fromJson(Map<String, dynamic> json) {
    return QuizAnswerDetails(
      id: json['id'],
      quizId: json['quizId'],
      quizName: json['quizName'],
      quizType: json['quizType'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentCode: json['studentCode'],
      studentEmail: json['studentEmail'],
      semesterId: json['semesterId'],
      semesterName: json['semesterName'],
      lessonId: json['lessonId'],
      lessonName: json['lessonName'],
      weekId: json['weekId'],
      weekNumber: json['weekNumber'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      timeTaken: json['timeTaken'],
      timeLimit: json['timeLimit'],
      attemptNumber: json['attemptNumber'],
      maxAttempts: json['maxAttempts'],
      submissionDate: DateTime.parse(json['submissionDate']),
      autoGraded: json['autoGraded'],
      grade: json['grade'],
      finalGrade: json['finalGrade'],
      answers: (json['answers'] as List)
          .map((item) => QuizAnswerItem.fromJson(item))
          .toList(),
    );
  }
}

class QuizAnswerItem {
  final String type;
  final String question;
  final int questionGrade;
  final String userAnswer;
  final bool? isCorrect;

  QuizAnswerItem({
    required this.type,
    required this.question,
    required this.questionGrade,
    required this.userAnswer,
    this.isCorrect,
  });

  factory QuizAnswerItem.fromJson(Map<String, dynamic> json) {
    return QuizAnswerItem(
      type: json['type'],
      question: json['question'],
      questionGrade: json['questionGrade'],
      userAnswer: json['userAnswer'],
      isCorrect: json['isCorrect'],
    );
  }
}