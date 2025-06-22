class StudentSummary {
  final StudentInfo student;
  final List<SemesterSummary> semesters;

  StudentSummary({
    required this.student,
    required this.semesters,
  });

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    return StudentSummary(
      student: StudentInfo.fromJson(json['student']),
      semesters: (json['semesters'] as List)
          .map((semester) => SemesterSummary.fromJson(semester))
          .toList(),
    );
  }
}

class StudentInfo {
  final int id;
  final String name;
  final String code;

  StudentInfo({
    required this.id,
    required this.name,
    required this.code,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class SemesterSummary {
  final int id;
  final String name;
  final int semesterNo;
  final List<SubjectGrades> subjects;

  SemesterSummary({
    required this.id,
    required this.name,
    required this.semesterNo,
    required this.subjects,
  });

  factory SemesterSummary.fromJson(Map<String, dynamic> json) {
    return SemesterSummary(
      id: json['id'],
      name: json['name'],
      semesterNo: json['semesterNo'],
      subjects: (json['subjects'] as List)
          .map((subject) => SubjectGrades.fromJson(subject))
          .toList(),
    );
  }
}

class SubjectGrades {
  final int id;
  final String name;
  final String code;
  final QuizGrades finalQuizzes;
  final QuizGrades weekQuizzes;

  SubjectGrades({
    required this.id,
    required this.name,
    required this.code,
    required this.finalQuizzes,
    required this.weekQuizzes,
  });

  factory SubjectGrades.fromJson(Map<String, dynamic> json) {
    return SubjectGrades(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      finalQuizzes: QuizGrades.fromJson(json['finalQuizzes']),
      weekQuizzes: QuizGrades.fromJson(json['weekQuizzes']),
    );
  }

  double get totalPercentage {
    if (!finalQuizzes.hasQuizzes && !weekQuizzes.hasQuizzes) return 0.0;
    
    double finalPercentage = finalQuizzes.hasQuizzes 
        ? (finalQuizzes.totalScore / finalQuizzes.finalScore) * 100 
        : 0.0;
    double weekPercentage = weekQuizzes.hasQuizzes 
        ? (weekQuizzes.totalScore / weekQuizzes.finalScore) * 100 
        : 0.0;
    
    if (finalQuizzes.hasQuizzes && weekQuizzes.hasQuizzes) {
      return (finalPercentage + weekPercentage) / 2;
    } else if (finalQuizzes.hasQuizzes) {
      return finalPercentage;
    } else {
      return weekPercentage;
    }
  }

  String get gradeLevel {
    double percentage = totalPercentage;
    if (percentage >= 90) return 'A+';
    if (percentage >= 85) return 'A';
    if (percentage >= 80) return 'B+';
    if (percentage >= 75) return 'B';
    if (percentage >= 70) return 'C+';
    if (percentage >= 65) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }
}

class QuizGrades {
  final double totalScore;
  final double finalScore;
  final bool hasQuizzes;

  QuizGrades({
    required this.totalScore,
    required this.finalScore,
    required this.hasQuizzes,
  });

  factory QuizGrades.fromJson(Map<String, dynamic> json) {
    return QuizGrades(
      totalScore: (json['totalScore'] ?? 0).toDouble(),
      finalScore: (json['finalScore'] ?? 0).toDouble(),
      hasQuizzes: json['hasQuizzes'] ?? false,
    );
  }

  double get percentage {
    if (!hasQuizzes || finalScore == 0) return 0.0;
    return (totalScore / finalScore) * 100;
  }
}
