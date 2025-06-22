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
  final int? timeLimit;
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
    this.timeLimit,
    required this.attemptNumber,
    required this.maxAttempts,
    required this.submissionDate,
    required this.autoGraded,
    this.grade,
    required this.finalGrade,
    required this.answers,
  });

  factory QuizAnswerDetails.fromJson(Map<String, dynamic> json) {
    print('=== MODEL: QuizAnswerDetails.fromJson Debug ===');
    print('MODEL: Quiz ID: ${json['id']}, Name: ${json['quizName']}, Type: ${json['quizType']}');
    print('MODEL: Time Limit: ${json['timeLimit']} (${json['timeLimit'].runtimeType})');

    try {
      List<QuizAnswerItem> answers = [];
      final answersJson = json['answers'];

      if (answersJson is List) {
        print('MODEL: Processing ${answersJson.length} answers...');
        for (int i = 0; i < answersJson.length; i++) {
          try {
            final answerItem = QuizAnswerItem.fromJson(answersJson[i]);
            answers.add(answerItem);
          } catch (answerError) {
            print('MODEL: Error parsing answer $i: $answerError');
            throw Exception('Error parsing answer $i: $answerError');
          }
        }
      }

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
        timeLimit: json['timeLimit'], // Now nullable
        attemptNumber: json['attemptNumber'],
        maxAttempts: json['maxAttempts'],
        submissionDate: DateTime.parse(json['submissionDate']),
        autoGraded: json['autoGraded'],
        grade: json['grade'],
        finalGrade: json['finalGrade'],
        answers: answers,
      );
    } catch (e) {
      print('MODEL: Error in QuizAnswerDetails.fromJson: $e');
      rethrow;
    }
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
    print('=== MODEL: QuizAnswerItem.fromJson Debug ===');
    print('MODEL: Answer JSON: $json');

    try {
      final type = json['type'];
      final question = json['question'];
      final questionGrade = json['questionGrade'];
      final userAnswer = json['userAnswer'];
      final isCorrect = json['isCorrect'];

      print('MODEL: Answer fields - Type: $type, Grade: $questionGrade, IsCorrect: $isCorrect');
      print('MODEL: Question: $question');
      print('MODEL: User Answer: $userAnswer');

      // Validate required fields
      if (type == null) throw Exception('type field is null');
      if (question == null) throw Exception('question field is null');
      if (questionGrade == null) throw Exception('questionGrade field is null');
      if (userAnswer == null) throw Exception('userAnswer field is null');

      // Check if questionGrade is an int
      int parsedQuestionGrade;
      if (questionGrade is int) {
        parsedQuestionGrade = questionGrade;
      } else if (questionGrade is String) {
        parsedQuestionGrade = int.parse(questionGrade);
      } else {
        throw Exception('questionGrade is not int or string: ${questionGrade.runtimeType}');
      }

      print('MODEL: Parsed question grade: $parsedQuestionGrade');

      return QuizAnswerItem(
        type: type.toString(),
        question: question.toString(),
        questionGrade: parsedQuestionGrade,
        userAnswer: userAnswer.toString(),
        isCorrect: isCorrect,
      );
    } catch (e) {
      print('MODEL: Error in QuizAnswerItem.fromJson: $e');
      print('MODEL: Full Answer JSON: $json');
      rethrow;
    }
  }
}