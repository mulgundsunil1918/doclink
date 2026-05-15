import 'package:equatable/equatable.dart';

enum UserRole { doctor, patient, receptionist, admin }

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final UserRole role;
  final String fullName;
  final String? profilePhotoUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.role,
    required this.fullName,
    this.profilePhotoUrl,
    required this.createdAt,
  });

  bool get isDoctor => role == UserRole.doctor;
  bool get isPatient => role == UserRole.patient;
  bool get isReceptionist => role == UserRole.receptionist;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, phone, role, fullName];
}
