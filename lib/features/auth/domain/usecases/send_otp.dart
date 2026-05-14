import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendOtp {
  final AuthRepository _repo;
  const SendOtp(this._repo);

  Future<Either<Failure, void>> call(String phone) =>
      _repo.sendOtp(phone: phone);
}
