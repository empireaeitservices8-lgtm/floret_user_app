import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/sp_helper.dart';
import '../utils/sp_keys.dart' as sp_keys;

class ApiService {
  static const String baseUrl = 'https://florettechuser.pythonanywhere.com';
  static const String loginEndpoint = '/api/login/';
  static const String sendOtpEndpoint = '/api/otp/send/';
  static const String verifyOtpEndpoint = '/api/otp/verify/';
  static const String profileEndpoint = '/api/profile/';
  static const String homeEndpoint = '/api/home/';
  static const String walletBalanceEndpoint = '/api/wallet/balance/';
  static const String walletTransactionsEndpoint = '/api/wallet/transactions/';
  static const String walletTopupEndpoint = '/api/wallet/topup/';
  static const String rewardPointsEndpoint = '/api/reward-points/';
  static const String rewardPointsTransactionsEndpoint =
      '/api/reward-points/transactions/';
  static const String pickupsEndpoint = '/api/pickups/';

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
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!options.headers.containsKey('Authorization') ||
              options.headers['Authorization'] == null ||
              options.headers['Authorization'].toString().trim().isEmpty) {
            final token = await SpHelper.getString(sp_keys.keyToken) ??
                await SpHelper.getString('token') ??
                (await SharedPreferences.getInstance()).getString('token') ??
                (await SharedPreferences.getInstance()).getString(sp_keys.keyToken);
            if (token != null && token.trim().isNotEmpty) {
              options.headers['Authorization'] = 'Token ${token.trim()}';
            }
          }
          debugPrint('[ApiClient] REQUEST: ${options.method} ${options.uri}');
          debugPrint('[ApiClient] REQUEST Headers: ${options.headers}');
          debugPrint('[ApiClient] REQUEST Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[ApiClient] RESPONSE: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
          debugPrint('[ApiClient] RESPONSE Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('[ApiClient] ERROR: ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}');
          debugPrint('[ApiClient] ERROR Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

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

      // ✅ Debug: Log API Response Details (Display OTP for testing/development)
      debugPrint('================================================================');
      debugPrint('✅ [SEND OTP API RESPONSE]');
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

    // 🚀 Debug: Log API Request Details
    debugPrint('================================================================');
    debugPrint('🚀 [VERIFY OTP API REQUEST]');
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

  /// Sends an authenticated GET request to /api/profile/ using saved token
  Future<Response> getProfile({String? token}) async {
    final String fullUrl = '$baseUrl$profileEndpoint';

    // 1. Retrieve authentication token if not explicitly provided
    String? authToken = token;
    if (authToken == null || authToken.trim().isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('token');
    }

    if (authToken == null || authToken.trim().isEmpty) {
      debugPrint('❌ [GET PROFILE API] No authentication token found.');
      throw Exception('Authentication token not found. Please log in again.');
    }

    // 🚀 Debug: Log API Request Details
    debugPrint('================================================================');
    debugPrint('🚀 [GET PROFILE API REQUEST]');
    debugPrint('URL: $fullUrl');
    debugPrint('Method: GET');
    debugPrint('Authorization: Token $authToken');
    debugPrint('Default Headers: ${_dio.options.headers}');
    debugPrint('================================================================');

    try {
      final response = await _dio.get(
        profileEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Token ${authToken.trim()}',
          },
        ),
      );

      // ✅ Debug: Log API Response Details
      debugPrint('================================================================');
      debugPrint('✅ [GET PROFILE API RESPONSE]');
      debugPrint('URL: $fullUrl');
      debugPrint('Status Code: ${response.statusCode} ${response.statusMessage ?? ""}');
      debugPrint('Response Body (JSON):');
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
      debugPrint('❌ [GET PROFILE API ERROR]');
      debugPrint('Status Code: ${dioError.response?.statusCode}');
      debugPrint('Response Data: ${dioError.response?.data}');
      debugPrint('Error Type: ${dioError.type}');
      debugPrint('Error Message: ${dioError.message}');
      debugPrint('================================================================');

      // Preserve DioException if 401 Unauthorized for dedicated handling
      if (dioError.response?.statusCode == 401) {
        rethrow;
      }

      final errorMessage = parseDioError(dioError);
      throw Exception(errorMessage);
    } catch (e) {
      if (e is DioException) rethrow;
      debugPrint('================================================================');
      debugPrint('❌ [GET PROFILE UNEXPECTED ERROR]: $e');
      debugPrint('================================================================');
      throw Exception('An unexpected error occurred while fetching profile: $e');
    }
  }

  /// Helper to resolve authentication token from argument, SpHelper, or SharedPreferences
  Future<String?> _resolveAuthToken(String? token) async {
    if (token != null && token.trim().isNotEmpty) {
      return token.trim();
    }
    final spToken = await SpHelper.getString(sp_keys.keyToken);
    if (spToken != null && spToken.trim().isNotEmpty) {
      return spToken.trim();
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token')?.trim();
  }

  /// Generic authenticated GET request with complete debugging and error handling
  Future<Response> _authenticatedGet({
    required String endpoint,
    required String requestName,
    String? token,
  }) async {
    final String fullUrl = '$baseUrl$endpoint';
    final authToken = await _resolveAuthToken(token);

    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Token $authToken';
    }

    debugPrint('================================================================');
    debugPrint('🚀 [$requestName API REQUEST]');
    debugPrint('URL: $fullUrl');
    debugPrint('Method: GET');
    debugPrint('Headers: $headers');
    debugPrint('================================================================');

    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      debugPrint('================================================================');
      debugPrint('✅ [$requestName API RESPONSE]');
      debugPrint('URL: $fullUrl');
      debugPrint('Status Code: ${response.statusCode} ${response.statusMessage ?? ""}');
      debugPrint('Response Body (JSON):');
      try {
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      } catch (_) {
        debugPrint('${response.data}');
      }
      debugPrint('================================================================');

      return response;
    } on DioException catch (dioError) {
      debugPrint('================================================================');
      debugPrint('❌ [$requestName API ERROR]');
      debugPrint('Status Code: ${dioError.response?.statusCode}');
      debugPrint('Response Data: ${dioError.response?.data}');
      debugPrint('Error Type: ${dioError.type}');
      debugPrint('Error Message: ${dioError.message}');
      debugPrint('================================================================');

      if (dioError.response?.statusCode == 401) {
        rethrow;
      }
      final errorMessage = parseDioError(dioError);
      throw Exception(errorMessage);
    } catch (e) {
      if (e is DioException) rethrow;
      debugPrint('================================================================');
      debugPrint('❌ [$requestName UNEXPECTED ERROR]: $e');
      debugPrint('================================================================');
      throw Exception('An error occurred during $requestName: $e');
    }
  }

  /// Sends a GET request to /api/home/
  Future<Response> getHome({String? token}) async {
    return _authenticatedGet(
      endpoint: homeEndpoint,
      requestName: 'GET HOME',
      token: token,
    );
  }

  /// Sends a GET request to /api/wallet/balance/
  Future<Response> getWalletBalance({String? token}) async {
    return _authenticatedGet(
      endpoint: walletBalanceEndpoint,
      requestName: 'GET WALLET BALANCE',
      token: token,
    );
  }

  /// Sends a GET request to /api/wallet/transactions/
  Future<Response> getWalletTransactions({String? token}) async {
    return _authenticatedGet(
      endpoint: walletTransactionsEndpoint,
      requestName: 'GET WALLET TRANSACTIONS',
      token: token,
    );
  }

  /// Sends a GET request to /api/wallet/topup/
  Future<Response> getWalletTopup({String? token}) async {
    return _authenticatedGet(
      endpoint: walletTopupEndpoint,
      requestName: 'GET WALLET TOPUP',
      token: token,
    );
  }

  /// Sends a GET request to /api/reward-points/
  Future<Response> getRewardPoints({String? token}) async {
    return _authenticatedGet(
      endpoint: rewardPointsEndpoint,
      requestName: 'GET REWARD POINTS',
      token: token,
    );
  }

  /// Sends a GET request to /api/reward-points/transactions/
  Future<Response> getRewardPointsTransactions({String? token}) async {
    return _authenticatedGet(
      endpoint: rewardPointsTransactionsEndpoint,
      requestName: 'GET REWARD POINTS TRANSACTIONS',
      token: token,
    );
  }

  /// Sends a GET request to /api/pickups/
  Future<Response> getPickups({String? token}) async {
    return _authenticatedGet(
      endpoint: pickupsEndpoint,
      requestName: 'GET PICKUPS',
      token: token,
    );
  }

  /// Helper to convert DioException into clear user-friendly error messages
  String parseDioError(DioException error) => _parseDioError(error);

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
            // If errors are nested or mapped by field
            final firstValue = data.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          } else if (data is String) {
            return data;
          }
        }
        if (response?.statusCode == 401) {
          return 'Unauthorized: Your session has expired. Please log in again.';
        }
        if (response?.statusCode == 403) {
          return 'Access forbidden. You do not have permission to view this.';
        }
        if (response?.statusCode == 404) {
          return 'Requested profile not found. Please try again.';
        }
        if (response?.statusCode != null && response!.statusCode! >= 500) {
          return 'Server encountered an error (${response.statusCode}). Please try again later.';
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
