import 'Subject_Template.dart';

class Lesson {
  final int id;
  final String name;
  final int subjectId;
  final DateTime createdAt;
  final List<dynamic> items;
  final Subject? subject;

  Lesson({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.createdAt,
    required this.items,
    this.subject,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unnamed Lesson',
      subjectId: json['subjectId'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      items: json['Items'] as List<dynamic>? ?? [],
      subject: json['subject'] != null ? Subject.fromJson(json['subject'] as Map<String, dynamic>) : null,
    );
  }
}
