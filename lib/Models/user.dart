class User {
  final int id;
  final String email;
  final String name;
  final DateTime birthday;
  final String nationality;
  final String address;
  final String gender;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.birthday,
    required this.nationality,
    required this.address,
    required this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      birthday: DateTime.parse(json['birthday']),
      nationality: json['nationality'],
      address: json['Address'],
      gender: json['gender'],
    );
  }
}