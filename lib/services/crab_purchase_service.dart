import 'package:dio/dio.dart';
import '../models/crab_purchase_model.dart';
import 'local_storage_service.dart';

class ApiCrabPurchaseService {
  static const String baseUrl =
      'https://back-end-app-cua.onrender.com/crabPurchases';
  final Dio _dio;

  ApiCrabPurchaseService()
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

  Future<List<CrabPurchase>> getCrabPurchasesByDate(
      String depotId, DateTime date) async {
    try {
      String formattedDate = date.toIso8601String().split('T')[0];
      Response response = await _dio.get('/depot/$depotId/date/$formattedDate');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => CrabPurchase.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<CrabPurchase>> getCrabPurchasesByDateRange(
      String depotId, DateTime startDate, DateTime endDate) async {
    try {
      String formattedStartDate = startDate.toIso8601String();
      String formattedEndDate = endDate.toIso8601String();
      Response response = await _dio.get(
          '/depot/$depotId/date-range?startDate=$formattedStartDate&endDate=$formattedEndDate');
      if (response.statusCode == 200) {
        var data = response.data['message']['metadata'];
        if (data != null && data is List) {
          return data.map((e) => CrabPurchase.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}