import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ApiConfig.baseUrlKey) ?? ApiConfig.defaultBaseUrl();
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.baseUrlKey, url);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    final base = await getBaseUrl();
    return _dio.get<T>('$base$path', queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    final base = await getBaseUrl();
    return _dio.post<T>('$base$path', data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    final base = await getBaseUrl();
    return _dio.put<T>('$base$path', data: data);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) async {
    final base = await getBaseUrl();
    return _dio.patch<T>('$base$path', data: data);
  }

  Future<Response<T>> delete<T>(String path) async {
    final base = await getBaseUrl();
    return _dio.delete<T>('$base$path');
  }

  Future<Response<T>> postMultipart<T>(String path, FormData data) async {
    final base = await getBaseUrl();
    return _dio.post<T>(
      '$base$path',
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<Response<T>> putMultipart<T>(String path, FormData data) async {
    final base = await getBaseUrl();
    return _dio.post<T>(
      '$base$path',
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  String? parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return e.message ?? 'Network error';
  }
}
