import 'package:dio/dio.dart';
import '../models/api_response.dart';

class ApiService {
  final Dio _dio;
  String? _cookie;

  ApiService({String baseUrl = 'https://api.example.com'})
      : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      responseType: ResponseType.json,
    ),
  ) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_cookie != null) {
          options.headers['cookie'] = _cookie!;
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final setCookie = response.headers.map['set-cookie']?.first;
        if (setCookie != null) {
          _cookie = setCookie.split(';')[0];
        }
        handler.next(response);
      },
      onError: (DioException e, handler) {
        handler.next(e);
      },
    ));
  }

  void setCookie(String cookie) => _cookie = cookie;

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        required T Function(dynamic json) fromJson,
      }) async {
    try {
      final response =
      await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse<T>(
        data: fromJson(response.data['data']),
        message: response.data['message'] ?? '',
        status: response.data['status'] ?? true,
      );
    } on DioException catch (e) {
      return ApiResponse(data: null, message: e.message.toString(), status: false);
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
      String path, {
        required Map<String, dynamic> body,
        required T Function(dynamic json) fromJson,
      }) async {
    try {
      final response = await _dio.post(path, data: body);
      return ApiResponse<T>(
        data: fromJson(response.data['data']),
        message: response.data['message'] ?? '',
        status: response.data['status'] ?? true,
      );
    } on DioException catch (e) {
      return ApiResponse(data: null, message: e.message.toString(), status: false);
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
      String path, {
        required Map<String, dynamic> body,
        required T Function(dynamic json) fromJson,
      }) async {
    try {
      final response = await _dio.put(path, data: body);
      return ApiResponse<T>(
        data: fromJson(response.data['data']),
        message: response.data['message'] ?? '',
        status: response.data['status'] ?? true,
      );
    } on DioException catch (e) {
      return ApiResponse(data: null, message: e.message.toString(), status: false);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
      String path, {
        required T Function(dynamic json) fromJson,
      }) async {
    try {
      final response = await _dio.delete(path);
      return ApiResponse<T>(
        data: fromJson(response.data['data']),
        message: response.data['message'] ?? '',
        status: response.data['status'] ?? true,
      );
    } on DioException catch (e) {
      return ApiResponse(data: null, message: e.message.toString(), status: false);
    }
  }

  /// GET List with pagination support
  Future<ApiResponse<List<T>>> getList<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        required T Function(dynamic json) fromJson,
      }) async {
    try {
      final response =
      await _dio.get(path, queryParameters: queryParameters);
      final List<dynamic> list = response.data['data'] ?? [];
      return ApiResponse<List<T>>(
        data: list.map((e) => fromJson(e)).toList(),
        message: response.data['message'] ?? '',
        status: response.data['status'] ?? true,
      );
    } on DioException catch (e) {
      return ApiResponse(data: null, message: e.message.toString(), status: false);
    }
  }
}
