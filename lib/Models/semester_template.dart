import 'package:admin_dashboard/Models/Subject_Template.dart';

class SemesterTemplate {
  final int id;
  final int semesterNo;
  final String? name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Subject> subjects;
  final List<dynamic> semesters;  // FIX: Use dynamic if data type is unknown

  SemesterTemplate({
    required this.id,
    required this.semesterNo,
    this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.subjects,
    required this.semesters,
  });

  factory SemesterTemplate.fromJson(Map<String, dynamic> json) {
    return SemesterTemplate(
      id: json['id'],
      semesterNo: json['semesterNo'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      subjects: (json['Subjects'] as List<dynamic>)
          .map((subjectJson) => Subject.fromJson(subjectJson))
          .toList(),
      semesters: json['Semesters'] ?? [], // FIX: Ensure it's not null
    );
  }
}
