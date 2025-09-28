// lib/services/finance_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/payment.dart'; // tu modelo UI: id, concept, amount, dueDate, paid
import './api_service.dart'; // ya mete Authorization: Bearer <access>

class FinanceService {
  /// Lista lo que el usuario debe (cargos abiertos) y lo mapea a tu modelo Payment.
  static Future<List<Payment>> listPayments() async {
    final http.Response resp = await ApiService.get(
      '/api/payments/charges/?only_open=1&ordering=fecha_pago',
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }

    final List data = jsonDecode(resp.body) as List;
    return data.map<Payment>((raw) {
      final j = raw as Map<String, dynamic>;
      final amountStr = (j['amount'] ?? '0').toString();
      final status = (j['status'] ?? '').toString().toUpperCase();

      return Payment(
        // usamos el id del cargo como id de tu Payment UI
        id: (j['id']).toString(),
        concept: (j['price_type'] ?? 'Cargo').toString(),
        amount: double.tryParse(amountStr) ?? 0.0,
        dueDate: j['fecha_pago'] != null
            ? DateTime.parse(j['fecha_pago'])
            : null,
        paid: status == 'PAID',
      );
    }).toList();
  }

  /// Inicia un checkout de Stripe para un cargo (el id que pasas es el id del Charge).
  /// Devuelve la URL de Stripe para abrir en el navegador / Custom Tab.
  static Future<String> payPayment(String id) async {
    // id viene como String desde tu UI; el backend espera un entero
    final int chargeId = int.parse(id);

    final http.Response resp = await ApiService.post(
      '/api/payments/create-checkout-session/',
      {'charge_id': chargeId},
    );

    final Map<String, dynamic> body = jsonDecode(resp.body);
    if (resp.statusCode != 200) {
      throw Exception(body['error'] ?? 'No se pudo iniciar checkout');
    }

    // Asegúrate de que el backend devuelva "url": session.url (te lo recomendé antes).
    final url = (body['url'] ?? '').toString();
    if (url.isEmpty) {
      // fallback por si solo tienes sessionId (no ideal para móvil)
      throw Exception('El backend no devolvió la URL de checkout');
    }
    return url;
  }

  /// Busca el recibo (si ya se pagó) consultando el historial y filtrando por charge_id.
  /// Devuelve la receipt_url o null si aún no existe.
  static Future<String?> fetchReceipt(String chargeId) async {
    final http.Response resp = await ApiService.get(
      '/api/payments/payments/?kind=charge&status=SUCCEEDED',
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List data = jsonDecode(resp.body) as List;
    final match = data.cast<Map<String, dynamic>>().firstWhere(
      (p) => (p['charge_id']?.toString() ?? '') == chargeId,
      orElse: () => const {},
    );
    if (match.isEmpty) return null;
    final url = match['receipt_url'];
    return (url is String && url.isNotEmpty) ? url : null;
  }
}
