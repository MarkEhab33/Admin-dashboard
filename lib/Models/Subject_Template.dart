class Subject {
  final String? subjectName;
  final int? subjectId;
  final String? code;
  final int? teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject({
    this.subjectId,
    this.subjectName,
    this.code,
    this.teacherId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create a Subject object from JSON
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['id'],  // FIX: Use correct API field
      subjectName: json['name'],
      code: json['code'].toString(), // Ensure code is String
      teacherId: json['teacherId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert a Subject object to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'id': subjectId,
      'name': subjectName,
      'code': code,
      'teacherId': teacherId,
    };
  }
}
