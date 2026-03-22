class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;
  final int? code;
  final dynamic error;

  const ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.code,
    this.error,
  });

  // ✅ success(...)
  factory ApiResponse.success({
    required String message,
    T? data,
    int? code,
  }) {
    return ApiResponse<T>(
      status: true,
      message: message,
      data: data,
      code: code,
    );
  }

  // ❌ failure(...)
  factory ApiResponse.failure({
    required String message,
    int? code,
    dynamic error,
  }) {
    return ApiResponse<T>(
      status: false,
      message: message,
      code: code,
      error: error,
    );
  }

  bool get isSuccess => status;
  bool get isFailure => !status;
}
