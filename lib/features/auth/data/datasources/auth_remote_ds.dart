import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<void> sendOtp({required String phone});
  Future<UserModel> verifyOtp({required String phone, required String otp});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;
  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<void> sendOtp({required String phone}) async {
    try {
      await _client.auth.signInWithOtp(phone: phone, shouldCreateUser: true);
    } on AuthException catch (e) {
      throw AppAuthException(message: e.message);
    } catch (_) {
      throw const ServerException(message: 'Failed to send OTP');
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );
      final userId = response.user?.id;
      if (userId == null) {
        throw const AppAuthException(message: 'Verification failed');
      }

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(data);
    } on AuthException catch (e) {
      throw AppAuthException(message: e.message);
    } on AppAuthException {
      rethrow;
    } catch (_) {
      throw const ServerException(message: 'OTP verification failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {
      throw const ServerException(message: 'Sign out failed');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
