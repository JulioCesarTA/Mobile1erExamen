import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/notification.dart';
import './api_service.dart';

class NotificationService {
  /// Lista las reservas próximas del usuario autenticado
  static Future<List<ReservationNotification>> listUpcoming({
    int horas = 24,
  }) async {
    final http.Response resp = await ApiService.get(
      '/api/reservations/upcoming/?horas=$horas',
    );

    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    final List data = jsonDecode(resp.body) as List;
    return data
        .map<ReservationNotification>(
          (j) => ReservationNotification.fromJson(j as Map<String, dynamic>),
        )
        .toList();
  }
}
