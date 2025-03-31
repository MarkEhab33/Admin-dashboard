class LessonItem {
  final int id;
  final int lessonId;
  final String title;
  final String itemType;
  final String itemContent;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonItem({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.itemType,
    required this.itemContent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonItem.fromJson(Map<String, dynamic> json) {
    return LessonItem(
      id: json['id'],
      lessonId: json['LessonId'], // Note the capital 'L' in LessonId
      title: json['title'],
      itemType: json['itemType'],
      itemContent: json['itemContent'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
