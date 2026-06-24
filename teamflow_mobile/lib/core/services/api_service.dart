import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/api_response.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Future<void> _cookieReady;
  String? _cookie;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _failedRequestsQueue = [];


  ApiService({
    String? baseUrl,
  }) : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/api/v1/'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  ) {
    _cookieReady = _initCookie();

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _cookieReady;
          if (_cookie != null) {
            options.headers['cookie'] = _cookie!;
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final cookies = response.headers.map['set-cookie'];
          if (cookies != null) {
            final parsed = <String>[];

            for (final cookie in cookies) {
              final nameValue = cookie.split(';').first.trim();
              final name = nameValue.split('=').first.trim();

              if (name == 'accessToken' || name == 'refreshToken') {
                parsed.add(nameValue);
              }
            }

            if (parsed.isNotEmpty) {
              await _saveCookie(parsed.join('; '));
            }
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final path = requestOptions.path;

          if (error.response?.statusCode == 401) {
            // Prevent refresh loop if the request is login, register, or refresh itself
            if (path.contains('auth/login') ||
                path.contains('auth/register') ||
                path.contains('auth/refresh')) {
              await clearCookie();
              return handler.next(error);
            }

            if (_isRefreshing) {
              _failedRequestsQueue.add((options: requestOptions, handler: handler));
              return;
            }

            _isRefreshing = true;

            try {
              final refreshResponse = await _dio.post('auth/refresh');

              if (refreshResponse.statusCode == 200) {
                _isRefreshing = false;
                await _cookieReady;

                if (_cookie != null) {
                  requestOptions.headers['cookie'] = _cookie!;
                }

                for (final queued in _failedRequestsQueue) {
                  if (_cookie != null) {
                    queued.options.headers['cookie'] = _cookie!;
                  }
                  _dio.fetch(queued.options).then(
                    (res) => queued.handler.resolve(res),
                    onError: (err) => queued.handler.next(err),
                  );
                }
                _failedRequestsQueue.clear();

                final retryResponse = await _dio.fetch(requestOptions);
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              _isRefreshing = false;
              await clearCookie();

              for (final queued in _failedRequestsQueue) {
                queued.handler.next(error);
              }
              _failedRequestsQueue.clear();

              return handler.next(error);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /* ==================== COOKIE ==================== */

  Future<void> _initCookie() async {
    _cookie ??= await _storage.read(key: 'accessToken');
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

  Future<ApiResponse<T>> patch<T>(
      String path, {
        Map<String, dynamic>? body,
        required T Function(dynamic json) fromJson,
      }) {
    return _handleRequest<T>(
      request: () => _dio.patch(path, data: body),
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
      fromJson: (json) => (json as List).map((e) => fromJson(e)).toList(),
    );
  }
}