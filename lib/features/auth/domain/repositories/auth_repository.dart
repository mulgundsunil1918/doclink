import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, void>> sendOtp({required String phone});
  Future<Either<Failure, UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
