class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({this.message = 'Server error', this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network unavailable'});
}

class AppAuthException implements Exception {
  final String message;
  const AppAuthException({this.message = 'Auth error'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error'});
}
