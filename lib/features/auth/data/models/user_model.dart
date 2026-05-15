import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String? phone;
  final String role;
  final String name;
  final String? avatarUrl;
  final String createdAt;

  const UserModel({
    required this.id,
    this.phone,
    required this.role,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phone: json['phone'] as String?,
        role: json['role'] as String? ?? 'patient',
        name: json['name'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
        createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        phone: phone ?? '',
        role: _parseRole(role),
        fullName: name,
        profilePhotoUrl: avatarUrl,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      );

  static UserRole _parseRole(String role) => switch (role) {
        'doctor' => UserRole.doctor,
        'receptionist' => UserRole.receptionist,
        'admin' => UserRole.admin,
        _ => UserRole.patient,
      };
}
