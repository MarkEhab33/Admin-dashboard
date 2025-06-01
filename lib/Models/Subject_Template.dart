class Subject {
  final String? subjectName;
  final int? subjectId;
  final String? code;
  final int? teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SubCategory>? subCategories;

  Subject({
    this.subjectId,
    this.subjectName,
    this.code,
    this.teacherId,
    required this.createdAt,
    required this.updatedAt,
    this.subCategories,
  });

  // Create a Subject object from JSON
  factory Subject.fromJson(Map<String, dynamic> json) {
    List<SubCategory>? subCategoriesList;
    if (json['subCategories'] != null) {
      subCategoriesList = (json['subCategories'] as List)
          .map((v) => SubCategory.fromJson(v))
          .toList();
    }

    return Subject(
      subjectId: json['id'],  // FIX: Use correct API field
      subjectName: json['name'],
      code: json['code'].toString(), // Ensure code is String
      teacherId: json['teacherId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      subCategories: subCategoriesList,
    );
  }

  // Convert a Subject object to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'id': subjectId,
      'name': subjectName,
      'code': code,
      'teacherId': teacherId,
      if (subCategories != null)
        'subCategories': subCategories!.map((v) => v.toJson()).toList(),
    };
  }
}

class SubCategory {
  final int? id;
  final String? name;

  SubCategory({
    this.id,
    this.name,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
