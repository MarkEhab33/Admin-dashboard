class Week {
  final int id;
  final int weekNo;
  final int semesterId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  Week({
    required this.id,
    required this.weekNo,
    required this.semesterId,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory Week.fromJson(Map<String, dynamic> json) {
    return Week(
      id: json['id'],
      weekNo: json['weekNo'],
      semesterId: json['semesterId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekNo': weekNo,
      'semesterId': semesterId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}