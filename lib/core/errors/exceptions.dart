class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache Error']);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Network Error']);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException([this.message = 'Validation Error']);

  @override
  String toString() => 'ValidationException: $message';
}
