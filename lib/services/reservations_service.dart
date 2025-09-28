import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/area.dart';
import '../models/reservation.dart';
import './api_service.dart';

class ReservationsService {
  // 👉 Ajusta estos paths si tu backend usa otros
  static const String _areasPath = '/api/areas/';
  static const String _reservasPath = '/api/reservations/';

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  static String _extractError(dynamic body) {
    try {
      final obj = body is String ? jsonDecode(body) : body;
      if (obj is Map) {
        if (obj['detail'] != null) return obj['detail'].toString();
        // toma el primer campo con error
        for (final entry in obj.entries) {
          final v = entry.value;
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String) return v;
        }
      }
    } catch (_) {}
    return 'No se pudo crear la reserva.';
  }

  static Future<Reservation> createReservation({
    required int areaId,
    required DateTime fecha,
    required TimeOfDay horaInicio,
    required TimeOfDay horaFin,
  }) async {
    // payload con `area`
    final payloadArea = {
      'area': areaId,
      'fecha_reserva': _fmtDate(fecha),
      'hora_inicio': _fmtTime(horaInicio),
      'hora_fin': _fmtTime(horaFin),
    };

    http.Response resp = await ApiService.post(_reservasPath, payloadArea);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Reservation.fromJson(jsonDecode(resp.body));
    }

    // si falló, probamos con `area_id`
    final payloadAreaId = Map<String, dynamic>.from(payloadArea)
      ..remove('area')
      ..putIfAbsent('area_id', () => areaId);

    resp = await ApiService.post(_reservasPath, payloadAreaId);
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Reservation.fromJson(jsonDecode(resp.body));
    }

    // mensaje bonito del backend
    final msg = _extractError(resp.body);
    throw Exception(msg);
  }

  // -------- ÁREAS --------
  static Future<List<Area>> listAreas() async {
    final http.Response resp = await ApiService.get('$_areasPath');
    if (resp.statusCode != 200) {
      throw Exception('Áreas: ${resp.statusCode} ${resp.body}');
    }
    final List data = jsonDecode(resp.body) as List;
    return data.cast<Map<String, dynamic>>().map(Area.fromJson).toList();
  }

  // -------- MIS RESERVAS --------
  static Future<List<Reservation>> listMyReservations() async {
    final http.Response resp = await ApiService.get(
      '$_reservasPath?mine=1&ordering=-fecha_reserva,-id',
    );
    if (resp.statusCode != 200) {
      throw Exception('Reservas: ${resp.statusCode} ${resp.body}');
    }
    final List data = jsonDecode(resp.body) as List;
    return data.cast<Map<String, dynamic>>().map(Reservation.fromJson).toList();
  }

  // -------- CHECKOUT (opcional) --------
  static Future<String> startCheckoutForReservation(int reservationId) async {
    final http.Response resp = await ApiService.post(
      '/api/payments/create-checkout-session/',
      {'reservation_id': reservationId},
    );
    final Map<String, dynamic> data = jsonDecode(resp.body);
    if (resp.statusCode != 200) {
      throw Exception(data['error'] ?? 'No se pudo iniciar checkout');
    }
    final url = (data['url'] ?? '').toString();
    if (url.isEmpty) throw Exception('Backend no devolvió URL de checkout');
    return url;
  }
}
