abstract class ClientAdapter {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});

  Future<HttpResponse> post(String url, {Map<String, String>? headers, Object? body});

  Future<HttpResponse> put(String url, {Map<String, String>? headers, Object? body});

  Future<HttpResponse> patch(String url, {Map<String, String>? headers, Object? body});

  Future<HttpResponse> delete(String url, {Map<String, String>? headers, Object? body});
}

class HttpResponse {
  final int statusCode;
  final String body;

  HttpResponse({required this.statusCode, required this.body});
}
