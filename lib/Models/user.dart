class User {
  final int id;
  final String name;
  final String email;
  final DateTime birthday;
  final String nationality;
  final String address;
  final String gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.birthday,
    required this.nationality,
    required this.address,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print('Processing user JSON: $json'); // Debug print

    return User(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'].toString())
          : DateTime.now(),
      nationality: json['nationality']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
    );
  }
}
