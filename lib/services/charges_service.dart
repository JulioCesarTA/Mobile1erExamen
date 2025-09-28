import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_service.dart';
import '../models/payment.dart'; // id, concept, amount, dueDate, paid

/// Convierte el JSON de ChargeListSerializer -> tu modelo UI Payment.
Payment _mapChargeToPayment(Map<String, dynamic> j) {
  final amountStr = (j['amount'] ?? '0').toString();
  final status = (j['status'] ?? '').toString().toUpperCase();
  final due = j['fecha_pago'];
  return Payment(
    id: (j['id']).toString(), // usamos id del Charge
    concept: (j['price_type'] ?? 'Cargo').toString(), // nombre del tipo
    amount: double.tryParse(amountStr) ?? 0.0,
    dueDate: (due is String && due.isNotEmpty) ? DateTime.tryParse(due) : null,
    paid: status == 'PAID',
  );
}

class ChargesService {
  /// Lista SOLO los cargos del usuario (backend: /my-charges/)
  static Future<List<Payment>> listMine({
    int? propertyId,
    bool onlyOpen = true,
  }) async {
    final qp = StringBuffer('?ordering=fecha_pago');
    if (onlyOpen) qp.write('&only_open=1');
    if (propertyId != null) qp.write('&property_id=$propertyId');

    final http.Response resp = await ApiService.get(
      '/api/payments/my-charges/$qp',
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List data = jsonDecode(resp.body) as List;
    return data.cast<Map<String, dynamic>>().map(_mapChargeToPayment).toList();
  }

  /// Resumen (pendiente/pagado) SOLO del usuario
  static Future<Map<String, dynamic>> summaryMine({
    int? propertyId,
    bool onlyOpen = true,
  }) async {
    final qp = StringBuffer('?');
    if (onlyOpen) qp.write('only_open=1');
    if (propertyId != null) {
      if (qp.isNotEmpty) qp.write('&');
      qp.write('property_id=$propertyId');
    }

    final http.Response resp = await ApiService.get(
      '/api/payments/my-charges/summary/$qp',
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  /// Inicia Stripe Checkout para un chargeId (id de Payment en nuestra UI= id de Charge)
  /// Devuelve la URL de checkout para abrir en navegador.
  static Future<String> startCheckoutForCharge(String chargeId) async {
    final int id = int.parse(chargeId);

    final http.Response resp = await ApiService.post(
      '/api/payments/create-checkout-session/',
      {'charge_id': id},
    );

    // Log completo para depurar
    // (puedes quitarlo luego)
    // ignore: avoid_print
    print('🔎 create-checkout-session → ${resp.statusCode} ${resp.body}');

    Map<String, dynamic> data;
    try {
      data = jsonDecode(resp.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Respuesta inválida del servidor.');
    }

    if (resp.statusCode != 200) {
      throw Exception(data['error'] ?? 'No se pudo iniciar checkout');
    }

    // 1) Intentar URL directa del backend
    String url = (data['url'] ?? '').toString();

    // 2) Fallback: construir URL con sessionId si el backend no mandó 'url'
    //    (tu backend a veces devolvía solo {"sessionId": "..."}).
    if (url.isEmpty) {
      final sessionId = (data['sessionId'] ?? data['session_id'] ?? '')
          .toString();
      if (sessionId.isEmpty) {
        throw Exception(
          'El backend no devolvió la URL ni el sessionId de checkout',
        );
      }
      // Formato que Stripe usa en session.url
      url = 'https://checkout.stripe.com/c/pay/$sessionId';
    }

    // 3) Validar URL
    final uri = Uri.tryParse(url);
    final isHttp =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    if (!isHttp) {
      throw Exception('URL de checkout inválida: $url');
    }

    return url;
  }
}
