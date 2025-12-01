import 'package:admin_dashboard/Models/semester.dart';
import 'package:admin_dashboard/Models/user.dart';

class Student {
  final int id;

  final String studentCode;
  final String city;
  final String church;
  final String abEle3traf;
  final String deaconLevel;
  final String churchService;
  final String qualifications;
  final String personalIDFront;
  final String personalIDBack;
  final bool isVerified;
  final String tazkia;
  final User user;
  final List<Semester> semesters;
  final List<Semester> completedSemesters;

  Student({
    required this.id,

    required this.studentCode,
    required this.city,
    required this.church,
    required this.abEle3traf,
    required this.deaconLevel,
    required this.churchService,
    required this.qualifications,
    required this.personalIDFront,
    required this.personalIDBack,
    required this.isVerified,
    required this.tazkia,
    required this.user,
    required this.semesters,
    required this.completedSemesters,
  });

  // New factory constructor for summary view
  factory Student.fromSummaryJson(Map<String, dynamic> json) {
    print('Processing summary JSON: $json'); // Debug print

    // Handle potentially null ID
    int? rawId = json['id'];
    if (rawId == null) {
      print('Warning: null ID received in student data');
    }

    // Create user object with null safety
    Map<String, dynamic> userData = json['user'] as Map<String, dynamic>? ?? {};
    print('User data: $userData'); // Debug print

    // If user data doesn't have an ID, try to use the student's userId field
    if (userData['id'] == null || userData['id'] == 0) {
      // Check multiple possible field names for user ID
      int? foundUserId;

      if (json['userId'] != null) {
        foundUserId = json['userId'];
        print('Using userId from student data: ${json['userId']}');
      } else if (json['user_id'] != null) {
        foundUserId = json['user_id'];
        print('Using user_id from student data: ${json['user_id']}');
      } else if (json['userID'] != null) {
        foundUserId = json['userID'];
        print('Using userID from student data: ${json['userID']}');
      } else if (json['User'] != null && json['User']['id'] != null) {
        foundUserId = json['User']['id'];
        print('Using User.id from student data: ${json['User']['id']}');
      } else {
        print('Warning: No valid user ID found in student data');
        print('Available fields: ${json.keys.toList()}');
        if (userData.isNotEmpty) {
          print('User data fields: ${userData.keys.toList()}');
        }
      }

      if (foundUserId != null) {
        userData['id'] = foundUserId;
      }
    }

    return Student(
      id: rawId ?? 0, // Provide default value if null
      studentCode: json['studentCode']?.toString() ?? '',
      city: '',
      church: '',
      abEle3traf: '',
      deaconLevel: '',
      churchService: '',
      qualifications: '',
      personalIDFront: '',
      personalIDBack: '',
      isVerified: json['isVerified'] ?? false,
      tazkia: '',
      user: User.fromJson(userData),
      semesters: [],
      completedSemesters: [],
    );
  }

  // Original factory constructor for full details
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? 0,
      studentCode: json['studentCode'] ?? '',
      city: json['city'] ?? '',
      church: json['church'] ?? '',
      abEle3traf: json['AbEle3traf'] ?? '',
      deaconLevel: json['deaconLevel'] ?? '',
      churchService: json['churchService'] ?? '',
      qualifications: json['qualifications'] ?? '',
      personalIDFront: json['personalIDFront'] ?? '',
      personalIDBack: json['personalIDBack'] ?? '',
      isVerified: json['isVerified'] ?? false,
      tazkia: json['Tazkia'] ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : User(
              id: 0,
              name: '',
              email: '',
              birthday: DateTime.now(),
              nationality: '',
              address: '',
              gender: '',
              phone: '',
              profilePicture: json['profilePicture'] ?? '',
            ),
      semesters: (json['semesters'] as List<dynamic>?)?.map((e) =>
          Semester.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      completedSemesters: (json['completedSemesters'] as List<dynamic>?)?.map((e) =>
          Semester.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentCode': studentCode,
      'city': city,
      'church': church,
      'AbEle3traf': abEle3traf,
      'deaconLevel': deaconLevel,
      'churchService': churchService,
      'qualifications': qualifications,
      'personalIDFront': personalIDFront,
      'personalIDBack': personalIDBack,
      'isVerified': isVerified,
      'Tazkia': tazkia,

      // Note: User and Semester models would need toJson methods for full serialization
      // For now, we'll include basic user info
      'user': {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'gender': user.gender,
        'nationality': user.nationality,
        'address': user.address,
        'birthday': user.birthday.toIso8601String(),
        'profilePicture': user.profilePicture,
      },
      // Semesters would need their own toJson implementation
      'semesters': semesters.length,
      'completedSemesters': completedSemesters.length,
    };
  }
}



