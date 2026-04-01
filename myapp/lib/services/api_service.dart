import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<dynamic>> fetchPosts() async {
    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/posts',
        queryParameters: {'_limit': 10},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('API Error: ${e.message}');
      return [];
    }
  }
}
