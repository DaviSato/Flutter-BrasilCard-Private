import 'dart:io';

import 'package:brasil_crypto/core/adapters/http/client_adapter.dart';
import 'package:http/http.dart';

class HttpClient extends ClientAdapter {
  final Client _client = Client();
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  static const String _apiKey = 'CG-UokcmYVJqQf9fD3zxb4hAvgy';

  HttpClient();

  Future<Uri> getUri(String url) async {
    final String fullUrl;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      fullUrl = url;
    } else if (url.startsWith('/')) {
      fullUrl = '$_baseUrl$url${url.contains('?') ? '&' : '?'}x_cg_demo_api_key=$_apiKey';
    } else {
      fullUrl = '$_baseUrl/$url${url.contains('?') ? '&' : '?'}x_cg_demo_api_key=$_apiKey';
    }

    return Uri.parse(fullUrl);
  }

  Future<Map<String, String>?> getHeaders({Map<String, String>? headers}) async {
    headers ??= {};

    return {'Content-Type': 'application/json', ...headers};
  }

  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await _client
          .delete(
            await getUri(url),
            headers: await getHeaders(headers: headers),
            body: body,
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () async {
              return Response('Timeout error', 408);
            },
          );

      return HttpResponse(body: response.body, statusCode: response.statusCode);
    } on SocketException {
      return HttpResponse(body: 'No route to host. Please check your network connection.', statusCode: 404);
    } catch (e) {
      return HttpResponse(body: '', statusCode: 400);
    }
  }

  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .get(await getUri(url), headers: await getHeaders(headers: headers))
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () async {
              return Response('Timeout error', 408);
            },
          );

      return HttpResponse(body: response.body, statusCode: response.statusCode);
    } on SocketException {
      return HttpResponse(body: 'No route to host. Please check your network connection.', statusCode: 404);
    } catch (e) {
      return HttpResponse(body: '', statusCode: 400);
    }
  }

  @override
  Future<HttpResponse> patch(String url, {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await _client
          .patch(
            await getUri(url),
            headers: await getHeaders(headers: headers),
            body: body,
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () async {
              return Response('Timeout error', 408);
            },
          );

      return HttpResponse(body: response.body, statusCode: response.statusCode);
    } on SocketException {
      return HttpResponse(body: 'No route to host. Please check your network connection.', statusCode: 404);
    } catch (e) {
      return HttpResponse(body: '', statusCode: 400);
    }
  }

  @override
  Future<HttpResponse> post(String url, {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await _client
          .post(
            await getUri(url),
            headers: await getHeaders(headers: headers),
            body: body,
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () async {
              return Response('Timeout error', 408);
            },
          );

      return HttpResponse(body: response.body, statusCode: response.statusCode);
    } on SocketException {
      return HttpResponse(body: 'No route to host. Please check your network connection.', statusCode: 404);
    } catch (e) {
      return HttpResponse(body: '', statusCode: 400);
    }
  }

  @override
  Future<HttpResponse> put(String url, {Map<String, String>? headers, Object? body}) async {
    try {
      final response = await _client
          .put(
            await getUri(url),
            headers: await getHeaders(headers: headers),
            body: body,
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () async {
              return Response('Timeout error', 408);
            },
          );

      return HttpResponse(body: response.body, statusCode: response.statusCode);
    } on SocketException {
      return HttpResponse(body: 'No route to host. Please check your network connection.', statusCode: 404);
    } catch (e) {
      return HttpResponse(body: '', statusCode: 400);
    }
  }
}
