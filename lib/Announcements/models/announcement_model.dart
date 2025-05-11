class Announcement {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? meetingLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AnnouncementWeek>? weeks;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.meetingLink,
    required this.createdAt,
    required this.updatedAt,
    this.weeks,
  });

  // Create a copy of the announcement with updated fields
  Announcement copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? meetingLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AnnouncementWeek>? weeks,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      meetingLink: meetingLink ?? this.meetingLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weeks: weeks ?? this.weeks,
    );
  }

  // Convert announcement to a map for API requests
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'description': description,
    };

    if (imageUrl != null) data['imageUrl'] = imageUrl;
    if (meetingLink != null) data['meetingLink'] = meetingLink;
    if (weeks != null && weeks!.isNotEmpty) {
      data['weekIds'] = weeks!.map((week) => week.week.id).toList();
    }

    return data;
  }

  // Create an announcement from API response
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      meetingLink: json['meetingLink'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      weeks: json['weeks'] != null
          ? List<AnnouncementWeek>.from(json['weeks'].map((x) => AnnouncementWeek.fromJson(x)))
          : null,
    );
  }
}

class AnnouncementWeek {
  final int id;
  final int announcementId;
  final int weekId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Week week;

  AnnouncementWeek({
    required this.id,
    required this.announcementId,
    required this.weekId,
    required this.createdAt,
    required this.updatedAt,
    required this.week,
  });

  factory AnnouncementWeek.fromJson(Map<String, dynamic> json) {
    return AnnouncementWeek(
      id: json['id'],
      announcementId: json['announcementId'],
      weekId: json['weekId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      week: Week.fromJson(json['week']),
    );
  }
}

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
}
