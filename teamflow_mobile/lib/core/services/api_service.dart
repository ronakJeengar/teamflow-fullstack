import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_response.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cookie;

  ApiService({String baseUrl = 'http://10.0.2.2:3000/api/v1/'})
      : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  ) {
    _initCookie();

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_cookie != null) {
            options.headers['cookie'] = _cookie!;
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final setCookie = response.headers.map['set-cookie']?.first;
          if (setCookie != null) {
            final accessToken = setCookie.split(';').first;
            await _saveCookie(accessToken);
          }
          handler.next(response);
        },
      ),
    );
  }

  /* ==================== COOKIE ==================== */

  Future<void> _initCookie() async {
    _cookie = await _storage.read(key: 'accessToken');
  }

  Future<void> _saveCookie(String cookie) async {
    _cookie = cookie;
    await _storage.write(key: 'accessToken', value: cookie);
  }

  Future<void> clearCookie() async {
    _cookie = null;
    await _storage.delete(key: 'accessToken');
  }

  /* ==================== CORE HANDLER ==================== */

  Future<ApiResponse<T>> _handleRequest<T>({
    required Future<Response> Function() request,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await request();
      final body = response.data;

      return ApiResponse.success(
        message: body['message'] ?? 'Success',
        data: body['data'] != null ? fromJson(body['data']) : null,
        code: response.statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        return ApiResponse.failure(
          message: data['message'] ?? 'Request failed',
          code: statusCode,
          error: data,
        );
      }

      return ApiResponse.failure(
        message: _dioErrorMessage(e),
        code: statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.failure(
        message: 'Unexpected error occurred',
        error: e,
      );
    }
  }

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.receiveTimeout:
        return 'Server not responding';
      default:
        return 'Something went wrong';
    }
  }

  /* ==================== HTTP METHODS ==================== */

  Future<ApiResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        required T Function(dynamic json) fromJson,
      }) {
    return _handleRequest<T>(
      request: () => _dio.get(path, queryParameters: queryParameters),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(
      String path, {
        Map<String, dynamic>? body,
        required T Function(dynamic json) fromJson,
      }) {
    return _handleRequest<T>(
      request: () => _dio.post(path, data: body),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(
      String path, {
        Map<String, dynamic>? body,
        required T Function(dynamic json) fromJson,
      }) {
    return _handleRequest<T>(
      request: () => _dio.put(path, data: body),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
      String path, {
        required T Function(dynamic json) fromJson,
      }) {
    return _handleRequest<T>(
      request: () => _dio.delete(path),
      fromJson: fromJson,
    );
  }

  Future<ApiResponse<List<T>>> getList<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        required T Function(dynamic json) fromJson,
      }) {
    return _handleRequest<List<T>>(
      request: () => _dio.get(path, queryParameters: queryParameters),
      fromJson: (json) =>
          (json as List).map((e) => fromJson(e)).toList(),
    );
  }
}
