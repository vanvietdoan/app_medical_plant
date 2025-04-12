import 'role.dart';

class User {
  final int id;
  final String fullName;
  final String title;
  final String proof;
  final String specialty;
  final bool active;
  final String avatar;
  final String email;
  final Role? role;

  User({
    required this.id,
    required this.fullName,
    required this.title,
    required this.proof,
    required this.specialty,
    required this.active,
    required this.avatar,
    required this.email,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      title: json['title'] ?? '',
      proof: json['proof'] ?? '',
      specialty: json['specialty'] ?? '',
      active: json['active'] ?? false,
      avatar: json['avatar'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'title': title,
    'proof': proof,
    'specialty': specialty,
    'active': active,
    'avatar': avatar,
    'email': email,
    'role': role?.toJson(),
  };
} 