import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/api_response.dart';
import 'auth_storage.dart';

class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => 'ApiException($code): $message';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._();
  factory ApiClient() => _instance;
  ApiClient._();

  final String _baseUrl = ApiConstants.baseUrl;

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await AuthStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) async {
    final body = json.decode(utf8.decode(response.bodyBytes));
    final apiResp = ApiResponse<T>.fromJson(body, fromJsonT);

    if (response.statusCode == 401) {
      await AuthStorage.clearAll();
      throw ApiException(401, '登录已过期，请重新登录');
    }

    if (!apiResp.isSuccess) {
      throw ApiException(apiResp.code, apiResp.message);
    }

    return apiResp;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    T Function(dynamic)? fromJsonT,
    bool auth = true,
  }) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final response = await http
        .get(uri, headers: await _headers(auth: auth))
        .timeout(ApiConstants.connectTimeout);
    return _handleResponse(response, fromJsonT);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
    bool auth = true,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl$path'),
          headers: await _headers(auth: auth),
          body: body != null ? json.encode(body) : null,
        )
        .timeout(ApiConstants.connectTimeout);
    return _handleResponse(response, fromJsonT);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
    bool auth = true,
  }) async {
    final response = await http
        .put(
          Uri.parse('$_baseUrl$path'),
          headers: await _headers(auth: auth),
          body: body != null ? json.encode(body) : null,
        )
        .timeout(ApiConstants.connectTimeout);
    return _handleResponse(response, fromJsonT);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
    bool auth = true,
  }) async {
    final request = http.Request('DELETE', Uri.parse('$_baseUrl$path'));
    final headers = await _headers(auth: auth);
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    if (body != null) {
      request.body = json.encode(body);
      request.headers['Content-Type'] = 'application/json';
    }
    final streamedResp = await request
        .send()
        .timeout(ApiConstants.connectTimeout);
    final response = await http.Response.fromStream(streamedResp);
    return _handleResponse(response, fromJsonT);
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    Map<String, String>? fields,
    T Function(dynamic)? fromJsonT,
    String fileField = 'file',
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$path'));
    final headers = await _headers(auth: true);
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    request.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final streamedResp = await request
        .send()
        .timeout(ApiConstants.receiveTimeout);
    final response = await http.Response.fromStream(streamedResp);
    return _handleResponse(response, fromJsonT);
  }

  Future<http.StreamedResponse> postStream(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final request = http.Request('POST', Uri.parse('$_baseUrl$path'));
    final headers = await _headers(auth: true);
    headers['Accept'] = 'text/event-stream';
    request.headers.addAll(headers);
    request.body = json.encode(body);
    return request.send().timeout(ApiConstants.receiveTimeout);
  }
}
