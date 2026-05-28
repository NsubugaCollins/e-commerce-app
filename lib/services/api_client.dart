import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// A user-friendly exception with a clean message ready to display in the UI.
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      followRedirects: true,
      maxRedirects: 5,
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

  // ── Private helper: wraps any Dio call and converts errors into AppExceptions ──
  Future<Response<T>> _wrap<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw AppException(_parseDioError(e));
    } on SocketException {
      throw const AppException('Connect to internet and try again');
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  String _parseDioError(DioException e) {
    // Connection / socket / DNS failures
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connect to internet and try again';
    }

    // Server-returned validation or business-logic messages
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }

    return e.message ?? 'Something went wrong. Please try again.';
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    final base = await getBaseUrl();
    return _wrap(() => _dio.get<T>('$base$path', queryParameters: query));
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    final base = await getBaseUrl();
    return _wrap(() => _dio.post<T>('$base$path', data: data));
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    final base = await getBaseUrl();
    return _wrap(() => _dio.put<T>('$base$path', data: data));
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) async {
    final base = await getBaseUrl();
    return _wrap(() => _dio.patch<T>('$base$path', data: data));
  }

  Future<Response<T>> delete<T>(String path) async {
    final base = await getBaseUrl();
    return _wrap(() => _dio.delete<T>('$base$path'));
  }

  Future<Response<T>> postMultipart<T>(String path, FormData data) async {
    final base = await getBaseUrl();
    return _wrap(() => _dio.post<T>(
          '$base$path',
          data: data,
          options: Options(contentType: 'multipart/form-data'),
        ));
  }

  Future<Response<T>> putMultipart<T>(String path, FormData data) async {
    final base = await getBaseUrl();
    return _wrap(() => _dio.put<T>(
          '$base$path',
          data: data,
          options: Options(contentType: 'multipart/form-data'),
        ));
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Legacy helper kept for compatibility — prefer [_parseDioError] internally.
  String? parseError(DioException e) => _parseDioError(e);
}
