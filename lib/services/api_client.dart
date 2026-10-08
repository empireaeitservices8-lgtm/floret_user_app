import 'package:dio/dio.dart';
import 'package:floret_app/services/api_endpoints.dart';

class ApiClient {
  final Dio dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        "Content-Type": "application/json",
      }));

  Future<Response> get(String endpoint) async {
    return await dio.get(endpoint);
  }

  Future<Response> post(
    String endpoint, {
    dynamic data,
    Options? options,
  }) async {
    return await dio.post(endpoint, data: data, options: options);
  }
}
