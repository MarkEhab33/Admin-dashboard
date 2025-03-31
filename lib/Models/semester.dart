import 'package:admin_dashboard/Models/semester_template.dart';
import 'package:admin_dashboard/Models/student.dart';
import 'week.dart';

class Semester {
  final int id;
  final int semesterTemplateId;
  final int year;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SemesterTemplate semesterTemplate;
  final List<Student> students;
  final List<dynamic> teachers;
  final List<Week> weeks;

  Semester({
    required this.id,
    required this.semesterTemplateId,
    required this.year,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
    required this.semesterTemplate,
    required this.students,
    required this.teachers,
    required this.weeks,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] ?? 0,
      semesterTemplateId: json['semesterTemplateId'] ?? 0,
      year: json['year'] ?? 0,
      name: json['name'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      isCurrent: json['isCurrent'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      semesterTemplate: json['semesterTemplate'] != null 
          ? SemesterTemplate.fromJson(json['semesterTemplate'])
          : SemesterTemplate(
              id: 0,
              semesterNo: 0,
              name: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              subjects: [],
              semesters: [],
            ),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => Student.fromJson(e))
          .toList() ?? [],
      teachers: json['Teachers'] as List<dynamic>? ?? [],
      weeks: (json['Weeks'] as List<dynamic>?)
          ?.map((e) => Week.fromJson(e))
          .toList() ?? [],
    );
  }
}


