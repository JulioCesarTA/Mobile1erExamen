import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class NoticePriority {
  static const alta = 'ALTA';
  static const media = 'MEDIA';
  static const baja = 'BAJA';
  static const values = [alta, media, baja];
}

class Notice {
  final int? id;
  final String title;
  final String content;
  final String priority; // ALTA | MEDIA | BAJA
  final String? createdBy; // StringRelatedField (e.g. email)
  final DateTime? createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdBy,
    required this.createdAt,
  });

  Notice copyWith({
    int? id,
    String? title,
    String? content,
    String? priority,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Notice.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final raw = json['created_at'];
    if (raw != null) created = DateTime.tryParse(raw.toString());

    return Notice(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      priority: (json['priority'] ?? NoticePriority.media).toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toBody() => {
        'title': title,
        'content': content,
        'priority': priority,
      };
}

class NoticesService {
  static const _base = '/api/notices/';

  static Future<List<Notice>> list() async {
    final http.Response resp = await ApiService.get(_base);
    if (resp.statusCode == 401) throw AuthError();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Error ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body);
    final List<dynamic> rawList =
        data is List ? data : (data is Map && data['results'] is List ? data['results'] : []);

    return rawList
        .whereType<Map>()
        .map<Notice>((m) => Notice.fromJson(
              m.map((k, v) => MapEntry(k.toString(), v)),
            ))
        .toList();
  }

  static Future<Notice> retrieve(int id) async {
    final resp = await ApiService.get('$_base$id/');
    if (resp.statusCode == 401) throw AuthError();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Error ${resp.statusCode}');
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    return Notice.fromJson(map);
  }

  static Future<Notice> create({
    required String title,
    required String content,
    String priority = NoticePriority.media,
  }) async {
    final resp = await ApiService.post(_base, {
      'title': title,
      'content': content,
      'priority': priority,
    });
    if (resp.statusCode == 401) throw AuthError();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    return Notice.fromJson(jsonDecode(resp.body));
  }

  static Future<Notice> update(Notice notice) async {
    if (notice.id == null) {
      throw Exception('ID requerido para actualizar');
    }
    final resp = await ApiService.put('$_base${notice.id}/', notice.toBody());
    if (resp.statusCode == 401) throw AuthError();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
    return Notice.fromJson(jsonDecode(resp.body));
  }

  static Future<void> delete(int id) async {
    final resp = await ApiService.delete('$_base$id/');
    if (resp.statusCode == 401) throw AuthError();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Error ${resp.statusCode}: ${resp.body}');
    }
  }
}

/// Excepción pública para capturar 401 desde las pantallas.
class AuthError implements Exception {
  @override
  String toString() => 'AuthError';
}
