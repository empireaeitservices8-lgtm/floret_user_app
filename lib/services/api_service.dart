import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'https://florettechuser.pythonanywhere.com';
  static const String loginEndpoint = '/api/login';
  static const String sendOtpEndpoint = '/api/otp/send/';
  static const String verifyOtpEndpoint = '/api/otp/verify/';

  final Dio _dio;

  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Sends a POST request to login endpoint with phone_number and otp
  Future<Response> login({
    required String phoneNumber,
    required String otp,
  }) async {
    final String fullUrl = '$baseUrl$loginEndpoint';
    final Map<String, dynamic> requestPayload = {
      'phone_number': phoneNumber,
      'otp': otp,
    };

    // 🚀 Debug: Log API Request Details
    debugPrint('================================================================');
    debugPrint('🚀 [LOGIN API REQUEST]');
    debugPrint('URL: $fullUrl');
    debugPrint('Method: POST');
    debugPrint('Headers: ${_dio.options.headers}');
    debugPrint('Payload:');
    try {
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestPayload));
    } catch (_) {
      debugPrint('$requestPayload');
    }
    debugPrint('================================================================');

    try {
      final response = await _dio.post(
        loginEndpoint,
        data: requestPayload,
      );

      // ✅ Debug: Log API Response Details
      debugPrint('================================================================');
      debugPrint('✅ [LOGIN API RESPONSE]');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data:');
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      } catch (_) {
        debugPrint('${response.data}');
      }
      debugPrint('================================================================');

      return response;
    } on DioException catch (dioError) {
      // ❌ Debug: Log Dio Error Details
      debugPrint('================================================================');
      debugPrint('❌ [LOGIN API ERROR]');
      debugPrint('Status Code: ${dioError.response?.statusCode}');
      debugPrint('Response Data: ${dioError.response?.data}');
      debugPrint('Error Type: ${dioError.type}');
      debugPrint('Error Message: ${dioError.message}');
      debugPrint('================================================================');

      final errorMessage = _parseDioError(dioError);
      throw Exception(errorMessage);
    } catch (e) {
      // ❌ Debug: Log Unexpected Error
      debugPrint('================================================================');
      debugPrint('❌ [LOGIN UNEXPECTED ERROR]: $e');
      debugPrint('================================================================');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Sends a POST request to /api/otp/send/ with the given phone number
  Future<Response> sendOtp(String phoneNumber) async {
    final String fullUrl = '$baseUrl$sendOtpEndpoint';
    final Map<String, dynamic> requestPayload = {
      'phone_number': phoneNumber,
    };

    // 🚀 Debug: Log API Request Details
    debugPrint('================================================================');
    debugPrint('🚀 [SEND OTP API REQUEST]');
    debugPrint('URL: $fullUrl');
    debugPrint('Method: POST');
    debugPrint('Headers: ${_dio.options.headers}');
    debugPrint('Payload:');
    try {
      debugPrint(const JsonEncoder.withIndent('  ').convert(requestPayload));
    } catch (_) {
      debugPrint('$requestPayload');
    }
    debugPrint('================================================================');

    try {
      final response = await _dio.post(
        sendOtpEndpoint,
        data: requestPayload,
      );

      // ✅ Debug: Log API Response Details (Security: Redact OTP)
      debugPrint('================================================================');
      debugPrint('✅ [SEND OTP API RESPONSE]');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data:');
      try {
        final Map<String, dynamic> safeLogData = Map<String, dynamic>.from(
          response.data is Map ? response.data as Map : {},
        );
        if (safeLogData.containsKey('otp')) {
          safeLogData['otp'] = '**** [REDACTED FOR SECURITY]';
        }
        debugPrint(const JsonEncoder.withIndent('  ').convert(safeLogData));
      } catch (_) {
        debugPrint('${response.statusCode} OK');
      }
      debugPrint('================================================================');

      return response;
    } on DioException catch (dioError) {
      // ❌ Debug: Log Dio Error Details
      debugPrint('================================================================');
      debugPrint('❌ [SEND OTP API ERROR]');
      debugPrint('Status Code: ${dioError.response?.statusCode}');
      debugPrint('Response Data: ${dioError.response?.data}');
      debugPrint('Error Type: ${dioError.type}');
      debugPrint('Error Message: ${dioError.message}');
      debugPrint('================================================================');

      final errorMessage = _parseDioError(dioError);
      throw Exception(errorMessage);
    } catch (e) {
      // ❌ Debug: Log Unexpected Error
      debugPrint('================================================================');
      debugPrint('❌ [SEND OTP UNEXPECTED ERROR]: $e');
      debugPrint('================================================================');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Sends a POST request to /api/otp/verify/ with phone_number and otp
  Future<Response> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final String fullUrl = '$baseUrl$verifyOtpEndpoint';
    final Map<String, dynamic> requestPayload = {
      'phone_number': phoneNumber,
      'otp': otp,
    };

    // 🚀 Debug: Log API Request Details (Mask OTP for security)
    final Map<String, dynamic> safeLogPayload = {
      'phone_number': phoneNumber,
      'otp': '**** [REDACTED FOR SECURITY]',
    };
    debugPrint('================================================================');
    debugPrint('🚀 [VERIFY OTP API REQUEST]');
    debugPrint('URL: $fullUrl');
    debugPrint('Method: POST');
    debugPrint('Headers: ${_dio.options.headers}');
    debugPrint('Payload:');
    try {
      debugPrint(const JsonEncoder.withIndent('  ').convert(safeLogPayload));
    } catch (_) {
      debugPrint('$safeLogPayload');
    }
    debugPrint('================================================================');

    try {
      final response = await _dio.post(
        verifyOtpEndpoint,
        data: requestPayload,
      );

      // ✅ Debug: Log API Response Details
      debugPrint('================================================================');
      debugPrint('✅ [VERIFY OTP API RESPONSE]');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Data:');
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      } catch (_) {
        debugPrint('${response.data}');
      }
      debugPrint('================================================================');

      return response;
    } on DioException catch (dioError) {
      // ❌ Debug: Log Dio Error Details
      debugPrint('================================================================');
      debugPrint('❌ [VERIFY OTP API ERROR]');
      debugPrint('Status Code: ${dioError.response?.statusCode}');
      debugPrint('Response Data: ${dioError.response?.data}');
      debugPrint('Error Type: ${dioError.type}');
      debugPrint('Error Message: ${dioError.message}');
      debugPrint('================================================================');

      final errorMessage = _parseDioError(dioError);
      throw Exception(errorMessage);
    } catch (e) {
      // ❌ Debug: Log Unexpected Error
      debugPrint('================================================================');
      debugPrint('❌ [VERIFY OTP UNEXPECTED ERROR]: $e');
      debugPrint('================================================================');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Helper to convert DioException into clear user-friendly error messages
  String _parseDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond. Please try again later.';
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null && response.data != null) {
          final data = response.data;
          if (data is Map) {
            // Check for common error response keys
            if (data.containsKey('message')) {
              return data['message'].toString();
            }
            if (data.containsKey('detail')) {
              return data['detail'].toString();
            }
            if (data.containsKey('error')) {
              return data['error'].toString();
            }
            // If errors are nested or mapped by field (e.g., {"otp": ["Invalid OTP"]})
            final firstValue = data.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          } else if (data is String) {
            return data;
          }
        }
        return 'Server returned error: ${response?.statusCode ?? 'Unknown'}';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please verify your network and retry.';
      case DioExceptionType.unknown:
      default:
        return error.message ?? 'Network error occurred. Please try again.';
    }
  }
}
