class SimpleStudent {
  final int id;
  final String name;
  final String code;

  SimpleStudent({
    required this.id,
    required this.name,
    required this.code,
  });

  factory SimpleStudent.fromJson(Map<String, dynamic> json) {
    return SimpleStudent(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  @override
  String toString() {
    return 'SimpleStudent{id: $id, name: $name, code: $code}';
  }
}
