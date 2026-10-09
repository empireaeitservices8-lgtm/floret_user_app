import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:floret_app/services/api_endpoints.dart';
import 'package:floret_app/helpers/sp_helper.dart';
import 'package:floret_app/utils/sp_keys.dart' as sp_keys;

class ApiClient {
  late final Dio dio;

  ApiClient({Dio? customDio}) {
    dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
          ),
        );

    dio.interceptors.add(
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

  Future<Response> get(String endpoint, {Options? options}) async {
    return await dio.get(endpoint, options: options);
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    return await dio.post(endpoint, data: data, options: options);
  }
}
