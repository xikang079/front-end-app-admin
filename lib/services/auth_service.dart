import 'package:dio/dio.dart';
import '../models/user_model.dart';

class ApiAuthService {
  static const String baseUrl = 'https://back-end-app-cua.onrender.com';
  final Dio _dio;

  ApiAuthService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
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

  Future<User?> login(String username, String password) async {
    try {
      Response response = await _dio.post(
        '/auths/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        var user = User.fromJson(data['user']);
        user.accessToken = data['accessToken'];
        user.refreshToken = data['refreshToken'];
        return user;
      } else {
        return null;
      }
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  Future<bool> checkTokenValidity(String token, String userId) async {
    try {
      Response response = await _dio.get(
        '/auths/check-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-user-id': userId,
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<User?> fetchUserDetails(String token, String userId) async {
    try {
      Response response = await _dio.get(
        '/auths/info',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-user-id': userId,
          },
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['message']['metadata']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
