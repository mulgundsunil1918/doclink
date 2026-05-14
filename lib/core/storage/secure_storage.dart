import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  ),
);

class SecureStorageService {
  final FlutterSecureStorage _storage;
  SecureStorageService(this._storage);

  static const _tokenKey = 'auth_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<void> saveRole(String role) =>
      _storage.write(key: _roleKey, value: role);
  Future<String?> getRole() => _storage.read(key: _roleKey);
  Future<void> clearAll() => _storage.deleteAll();
}

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(ref.watch(secureStorageProvider)),
);
