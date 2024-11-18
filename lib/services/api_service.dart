// lib/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  static Future<String> generateDiary(String inputText) async {
    try {
      var response = await Dio().post(
        'http://your-flask-server-url/generate',
        data: {'text': inputText},
      );
      return response.data['generated_text'];
    } catch (e) {
      print('Error generating diary: $e');
      return '';
    }
  }
}