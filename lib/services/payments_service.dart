import 'dart:convert';
import 'package:http/http.dart' as http;
import './api_service.dart';

class PaymentHistoryItem {
  final int id;
  final int? chargeId;
  final String priceType;
  final String amount; // string "200.00"
  final String status; // SUCCEEDED, FAILED, PENDING...
  final String? receiptUrl;

  PaymentHistoryItem({
    required this.id,
    required this.chargeId,
    required this.priceType,
    required this.amount,
    required this.status,
    this.receiptUrl,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> j) =>
      PaymentHistoryItem(
        id: j['id'],
        chargeId: j['charge_id'],
        priceType: (j['price_type'] ?? '').toString(),
        amount: (j['amount'] ?? '0.00').toString(),
        status: (j['status'] ?? '').toString(),
        receiptUrl: (j['receipt_url'] ?? '').toString().isEmpty
            ? null
            : (j['receipt_url'] as String),
      );
}

class PaymentsService {
  /// Historial de pagos de CARGOS del usuario logueado
  static Future<List<PaymentHistoryItem>> listSucceededCharges() async {
    final http.Response resp = await ApiService.get(
      '/api/payments/payments/?kind=charge&status=SUCCEEDED',
    );
    if (resp.statusCode != 200) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    final List data = jsonDecode(resp.body) as List;
    return data
        .cast<Map<String, dynamic>>()
        .map(PaymentHistoryItem.fromJson)
        .toList();
  }

  /// Busca receipt_url para un chargeId ya pagado (si existe)
  static Future<String?> getReceiptUrlForCharge(String chargeId) async {
    final list = await listSucceededCharges();
    final m = list.firstWhere(
      (e) => (e.chargeId?.toString() ?? '') == chargeId,
      orElse: () => PaymentHistoryItem(
        id: -1,
        chargeId: null,
        priceType: '',
        amount: '0',
        status: '',
      ),
    );
    if (m.id == -1) return null;
    return m.receiptUrl;
  }
}
