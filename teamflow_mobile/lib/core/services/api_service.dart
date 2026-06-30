import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:teamflow_mobile/core/constants/api_endpoints.dart';
import '../models/api_response.dart';

enum SyncStatus { synced, pending, offline, retrying }

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Future<void> _cookieReady;
  String? _cookie;
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _failedRequestsQueue = [];

  final ValueNotifier<SyncStatus> syncStatusNotifier = ValueNotifier<SyncStatus>(SyncStatus.synced);
  bool _isSyncing = false;

  ApiService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl:
              baseUrl ??
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: ApiEndpoints.baseUrl,
              ),
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
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
              _failedRequestsQueue.add((
                options: requestOptions,
                handler: handler,
              ));
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
                  _dio
                      .fetch(queued.options)
                      .then(
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
    required String path,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final cacheKey = 'cache_${method}_${path}';
    try {
      final response = await request();
      final responseBody = response.data;

      // Cache successful GET results
      if (method == 'GET' && responseBody['data'] != null) {
        await _storage.write(key: cacheKey, value: jsonEncode(responseBody['data']));
      }

      // Trigger background sync
      _triggerSync();

      return ApiResponse.success(
        message: responseBody['message'] ?? 'Success',
        data: responseBody['data'] != null ? fromJson(responseBody['data']) : null,
        code: response.statusCode,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      // Handle offline reads
      if (method == 'GET' && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout)) {
        final cached = await _storage.read(key: cacheKey);
        if (cached != null) {
          final decoded = jsonDecode(cached);
          return ApiResponse.success(
            message: 'Loaded from local cache (offline)',
            data: fromJson(decoded),
            code: 200,
          );
        }
      }

      // Handle offline writes (queue mutations)
      if (method != 'GET' && (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout)) {
        await _queueMutation(path, method, body);
        return ApiResponse.success(
          message: 'Offline: Mutation queued successfully',
          data: null,
          code: 202,
        );
      }

      if (responseData is Map<String, dynamic>) {
        return ApiResponse.failure(
          message: responseData['message'] ?? 'Request failed',
          code: statusCode,
          error: responseData,
        );
      }

      return ApiResponse.failure(
        message: _dioErrorMessage(e),
        code: statusCode,
        error: e,
      );
    } catch (e) {
      if (method == 'GET') {
        final cached = await _storage.read(key: cacheKey);
        if (cached != null) {
          final decoded = jsonDecode(cached);
          return ApiResponse.success(
            message: 'Loaded from local cache (offline)',
            data: fromJson(decoded),
            code: 200,
          );
        }
      }
      return ApiResponse.failure(
        message: 'Unexpected error occurred',
        error: e,
      );
    }
  }

  Future<void> _queueMutation(String path, String method, Map<String, dynamic>? body) async {
    try {
      final queueStr = await _storage.read(key: 'offline_mutations_queue') ?? '[]';
      final List<dynamic> queue = jsonDecode(queueStr);
      
      // Prevent duplicates: if there is already an identical mutation in the queue, skip it
      final isDuplicate = queue.any((item) => 
        item['path'] == path && 
        item['method'] == method && 
        jsonEncode(item['body']) == jsonEncode(body)
      );
      if (isDuplicate) return;

      queue.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'path': path,
        'method': method,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
        'retries': 0,
      });
      await _storage.write(key: 'offline_mutations_queue', value: jsonEncode(queue));
      syncStatusNotifier.value = SyncStatus.pending;
    } catch (e) {
      // Fail silently
    }
  }

  void _triggerSync() {
    syncOfflineMutations().catchError((err) {
      // Ignored
    });
  }

  Future<void> syncOfflineMutations() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queueStr = await _storage.read(key: 'offline_mutations_queue');
      if (queueStr == null || queueStr == '[]') {
        syncStatusNotifier.value = SyncStatus.synced;
        _isSyncing = false;
        return;
      }

      final List<dynamic> queue = jsonDecode(queueStr);
      final remaining = <dynamic>[];
      bool networkErrorEncountered = false;

      syncStatusNotifier.value = SyncStatus.retrying;

      for (final mutation in queue) {
        if (networkErrorEncountered) {
          remaining.add(mutation);
          continue;
        }

        final path = mutation['path'] as String;
        final method = mutation['method'] as String;
        final body = mutation['body'] as Map<String, dynamic>?;
        final retries = (mutation['retries'] as int? ?? 0) + 1;

        try {
          final headers = {
            'x-sync-timestamp': mutation['timestamp'] ?? DateTime.now().toIso8601String(),
          };

          if (method == 'POST') {
            await _dio.post(path, data: body, options: Options(headers: headers));
          } else if (method == 'PATCH') {
            await _dio.patch(path, data: body, options: Options(headers: headers));
          } else if (method == 'PUT') {
            await _dio.put(path, data: body, options: Options(headers: headers));
          } else if (method == 'DELETE') {
            await _dio.delete(path, options: Options(headers: headers));
          }
        } catch (e) {
          if (e is DioException) {
            final isNetworkError = e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout ||
                e.response == null;

            if (isNetworkError) {
              if (retries < 5) {
                networkErrorEncountered = true;
                mutation['retries'] = retries;
                remaining.add(mutation);
              } else {
                // Drop after 5 connection retries to prevent blocking the queue forever
                debugPrint('[Offline Sync] Dropping mutation after 5 failed retries: $path');
              }
            } else {
              // Client/server validation or conflict error (e.g. 400, 401, 403, 409)
              // Discard to prevent blocking subsequent writes
              debugPrint('[Offline Sync] Discarding invalid mutation with status ${e.response?.statusCode}: $path');
            }
          } else {
            debugPrint('[Offline Sync] Discarding corrupt mutation: $path');
          }
        }
      }

      await _storage.write(key: 'offline_mutations_queue', value: jsonEncode(remaining));
      
      if (networkErrorEncountered) {
        syncStatusNotifier.value = SyncStatus.offline;
      } else {
        syncStatusNotifier.value = remaining.isEmpty ? SyncStatus.synced : SyncStatus.pending;
      }
    } catch (e) {
      debugPrint('[Offline Sync Error] Failed to process queue: $e');
      syncStatusNotifier.value = SyncStatus.offline;
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<Map<String, dynamic>>> getQueuedMutations() async {
    try {
      final queueStr = await _storage.read(key: 'offline_mutations_queue');
      if (queueStr == null) return [];
      final List<dynamic> decoded = jsonDecode(queueStr);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearQueue() async {
    await _storage.write(key: 'offline_mutations_queue', value: '[]');
    syncStatusNotifier.value = SyncStatus.synced;
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
      path: path,
      method: 'GET',
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
      path: path,
      method: 'POST',
      body: body,
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
      path: path,
      method: 'PUT',
      body: body,
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
      path: path,
      method: 'PATCH',
      body: body,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic json) fromJson,
  }) {
    return _handleRequest<T>(
      request: () => _dio.delete(path),
      fromJson: fromJson,
      path: path,
      method: 'DELETE',
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
      path: path,
      method: 'GET',
    );
  }
}
