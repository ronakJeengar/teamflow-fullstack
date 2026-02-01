class ApiResponse<T> {
  final T? data;
  final String message;
  final bool status;

  ApiResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  /// Optional: factory for creating from JSON
  /// Note: for generic `T`, you must provide `fromJsonT` function
  factory ApiResponse.fromJson(
      Map<String, dynamic> json, {
        required T Function(dynamic json) fromJsonT,
      }) {
    final dataJson = json['data'];
    return ApiResponse<T>(
      data: dataJson != null ? fromJsonT(dataJson) : null,
      message: json['message'] ?? '',
      status: json['status'] ?? true,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T data) toJsonT) {
    return {
      'data': data != null ? toJsonT(data!) : null,
      'message': message,
      'status': status,
    };
  }
}
