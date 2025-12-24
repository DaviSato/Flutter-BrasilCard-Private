class RepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  RepositoryException({required this.message, this.code, this.originalException, this.stackTrace});

  factory RepositoryException.fromStatusCode(int statusCode, String body) {
    switch (statusCode) {
      case 400:
        return RepositoryException(message: 'Bad request: Invalid search parameters', code: 'BAD_REQUEST');
      case 404:
        return RepositoryException(message: 'Cryptocurrency not found', code: 'NOT_FOUND');
      case 429:
        return RepositoryException(message: 'Too many requests. Please try again later', code: 'RATE_LIMIT');
      case 500:
      case 502:
      case 503:
        return RepositoryException(message: 'Server error. Please try again later', code: 'SERVER_ERROR');
      default:
        return RepositoryException(message: 'An error occurred (HTTP $statusCode)', code: 'HTTP_ERROR_$statusCode');
    }
  }

  factory RepositoryException.networkError(String message) {
    return RepositoryException(message: message, code: 'NETWORK_ERROR');
  }

  factory RepositoryException.timeout() {
    return RepositoryException(message: 'Request timeout. Please check your connection', code: 'TIMEOUT');
  }

  factory RepositoryException.parseError(String message) {
    return RepositoryException(message: 'Failed to parse response: $message', code: 'PARSE_ERROR');
  }

  @override
  String toString() => message;
}
