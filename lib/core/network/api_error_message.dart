import 'package:dio/dio.dart';

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final payload = responseData['error'];
      if (payload is Map<String, dynamic> && payload['message'] is String) {
        return payload['message'] as String;
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Cannot reach the EKŌ API. Check your connection and try again.';
    }
    return error.message ?? 'The request could not be completed.';
  }
  return 'Something went wrong. Please try again.';
}
