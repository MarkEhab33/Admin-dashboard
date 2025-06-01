import 'package:admin_dashboard/Models/subject_grades.dart';

class GradeData {
  final Map<String, dynamic> semester;
  final Map<String, dynamic> student;
  final List<SubjectGrades> subjects;

  GradeData({
    required this.semester,
    required this.student,
    required this.subjects,
  });

  factory GradeData.fromJson(Map<String, dynamic> json) {
    return GradeData(
      semester: json['semester'],
      student: json['student'],
      subjects: (json['subjects'] as List)
          .map((subject) => SubjectGrades.fromJson(subject))
          .toList(),
    );
  }
}