import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository _repo;
  const VerifyOtp(this._repo);

  Future<Either<Failure, UserEntity>> call({
    required String phone,
    required String otp,
  }) =>
      _repo.verifyOtp(phone: phone, otp: otp);
}
