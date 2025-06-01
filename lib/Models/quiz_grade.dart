class SubCategory {
  final int id;
  final String name;

  SubCategory({
    required this.id,
    required this.name,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}

class QuizGrade {
  final String name;
  final int? userGrade;
  final int finalGrade;
  final String? type;
  final DateTime? submissionDate;
  final SubCategory? subCategory;

  QuizGrade({
    required this.name,
    this.userGrade,
    required this.finalGrade,
    this.type,
    this.submissionDate,
    this.subCategory,
  });

  factory QuizGrade.fromJson(Map<String, dynamic> json) {
    return QuizGrade(
      name: json['name'],
      userGrade: json['userGrade'],
      finalGrade: json['finalGrade'],
      type: json['type'],
      submissionDate: json['submissionDate'] != null
          ? DateTime.parse(json['submissionDate'])
          : null,
      subCategory: json['subCategory'] != null
          ? SubCategory.fromJson(json['subCategory'])
          : null,
    );
  }
}