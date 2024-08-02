import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'local_storage_service.dart';

class UserService {
  static const String baseUrl = 'https://back-end-app-cua.onrender.com';
  final Dio _dio;

  UserService()
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
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        String? userId = await LocalStorageService.getUserId();
        if (userId != null) {
          options.headers['x-user-id'] = userId;
        }
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

  Future<List<User>> getAllUsers() async {
    try {
      Response response = await _dio.get('/auths/users');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'] as List;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Failed to load users: $e');
      rethrow;
    }
  }
}
