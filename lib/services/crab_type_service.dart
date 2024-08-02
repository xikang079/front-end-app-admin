import 'package:dio/dio.dart';
import '../models/crab_type_model.dart';
import 'local_storage_service.dart';

class ApiServiceCrabType {
  static const String baseUrl =
      'https://back-end-app-cua.onrender.com/crabTypes';
  final Dio _dio;

  ApiServiceCrabType()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await LocalStorageService.getToken();
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        return handler.next(error);
      },
    ));
  }

  Future<List<CrabType>> getAllCrabTypes() async {
    try {
      Response response = await _dio.get('/');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => CrabType.fromJson(e)).toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
