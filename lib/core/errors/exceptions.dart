class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException([this.message = 'Authentication error', this.code]);

  @override
  String toString() => 'AuthException: $message';
}
