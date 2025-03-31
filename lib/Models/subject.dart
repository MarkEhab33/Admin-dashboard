class Lesson {
  final int id;
  final String name;
  final int subjectId;
  final DateTime createdAt;
  final List<dynamic> items; // Assuming Items are dynamic; specify the type if known

  Lesson({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.createdAt,
    required this.items,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      name: json['name'],
      subjectId: json['subjectId'],
      createdAt: DateTime.parse(json['createdAt']),
      items: json['Items'], // Make sure to handle this correctly depending on the structure
    );
  }
}
