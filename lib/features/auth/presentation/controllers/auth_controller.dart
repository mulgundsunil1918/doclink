import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../data/datasources/auth_remote_ds.dart';
import '../../data/repositories/auth_repo_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';

final authRemoteDsProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(supabaseProvider)),
);

final authRepoProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDsProvider)),
);

class AuthController extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async => null;

  SendOtp get _sendOtp => SendOtp(ref.read(authRepoProvider));
  VerifyOtp get _verifyOtp => VerifyOtp(ref.read(authRepoProvider));

  Future<bool> sendOtp(String phone) async {
    state = const AsyncValue.loading();
    final result = await _sendOtp('+91$phone');
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<UserEntity?> verifyOtp(String phone, String otp) async {
    state = const AsyncValue.loading();
    final result = await _verifyOtp(phone: '+91$phone', otp: otp);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (user) {
        state = AsyncValue.data(user);
        return user;
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepoProvider).signOut();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity?>(AuthController.new);
