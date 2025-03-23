class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse({this.data, this.error}) : success = error == null;

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    if (json['message'] != null && json['message'] is String && json['message'].toString().contains('error')) {
      return ApiResponse(error: json['message'] as String);
    }
    return ApiResponse(data: fromJsonT(json));
  }
}