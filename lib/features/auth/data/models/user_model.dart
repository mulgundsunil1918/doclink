import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String role;
  final String fullName;
  final String? profilePhotoUrl;
  final bool isVerified;
  final String kycStatus;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.role,
    required this.fullName,
    this.profilePhotoUrl,
    this.isVerified = false,
    this.kycStatus = 'pending',
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        role: json['role'] as String? ?? 'patient',
        fullName: json['full_name'] as String? ?? '',
        profilePhotoUrl: json['profile_photo_url'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
        kycStatus: json['kyc_status'] as String? ?? 'pending',
        createdAt: json['created_at'] as String,
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        phone: phone,
        email: email,
        role: _parseRole(role),
        fullName: fullName,
        profilePhotoUrl: profilePhotoUrl,
        isVerified: isVerified,
        isKycApproved: kycStatus == 'approved',
        createdAt: DateTime.parse(createdAt),
      );

  static UserRole _parseRole(String role) => switch (role) {
        'doctor' => UserRole.doctor,
        'patient' => UserRole.patient,
        'receptionist' => UserRole.receptionist,
        'admin' => UserRole.admin,
        _ => UserRole.patient,
      };
}
