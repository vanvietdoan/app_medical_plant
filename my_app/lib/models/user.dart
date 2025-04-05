import 'role.dart';

class User {
  final int userId;
  final String fullName;
  final String email;
  final int roleId;
  final Role? role;
  final String specialty;
  final String? title;
  final String? proof;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? specialization;
  final int? experience;
  final String? bio;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roleId,
    required this.specialty,
    this.title,
    this.proof,
    this.role,
    this.avatarUrl,
    this.phoneNumber,
    this.specialization,
    this.experience,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      fullName: json['full_name'],
      email: json['email'],
      roleId: json['role_id'],
      specialty: json['specialty'] ?? '',
      title: json['title'],
      proof: json['proof'],
      role: json['role'] != null ? Role.fromJson(json['role']) : null,
      avatarUrl: json['avatar_url'],
      phoneNumber: json['phone_number'],
      specialization: json['specialization'],
      experience: json['experience'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'full_name': fullName,
    'email': email,
    'role_id': roleId,
    'specialty': specialty,
    'title': title,
    'proof': proof,
    'role': role?.toJson(),
    'avatar_url': avatarUrl,
    'phone_number': phoneNumber,
    'specialization': specialization,
    'experience': experience,
    'bio': bio,
  };
} 