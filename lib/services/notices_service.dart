import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/notice.dart';
import './api_service.dart';

class NoticesService {
  /// Lista todas las noticias del condominio
  static Future<List<Notice>> listNotices() async {
    final http.Response resp = await ApiService.get('/api/notices/');

    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    final List data = jsonDecode(resp.body) as List;
    return data
        .map<Notice>((j) => Notice.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
