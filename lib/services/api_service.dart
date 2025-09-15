// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class ApiService {
  // Para Android emulador contra tu PC usa 10.0.2.2 (host machine).
  // Para iOS Simulator suele ser http://127.0.0.1:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://backend-parcialsi2-production.up.railway.app',
  );

  static const _storage = FlutterSecureStorage();

  // -------------------------
  // Auth
  // -------------------------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$baseUrl/api/login/');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;

      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;
      if (access == null || refresh == null) {
        throw Exception('Respuesta del servidor sin tokens.');
      }

      // Guardamos tokens + datos útiles del usuario
      await _storage.write(key: 'access', value: access);
      await _storage.write(key: 'refresh', value: refresh);

      await _storage.write(key: 'email', value: (data['email'] ?? '').toString());
      await _storage.write(key: 'first_name', value: (data['first_name'] ?? '').toString());
      await _storage.write(key: 'last_name', value: (data['last_name'] ?? '').toString());
      await _storage.write(key: 'role', value: (data['role'] ?? '').toString());
      await _storage.write(
        key: 'extra_permissions',
        value: jsonEncode(data['extra_permissions'] ?? []),
      );

      return data;
    }

    // Mejoramos los errores
    String message = 'Error ${resp.statusCode}';
    try {
      final err = jsonDecode(resp.body);
      if (err is Map && err['detail'] != null) {
        message = err['detail'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }

  static Future<void> logout() async {
    // Si quisieras invalidar el refresh token en el server,
    // deberías implementar /api/token/blacklist/ (SimpleJWT) en el backend.
    await _storage.deleteAll();
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access');
    if (token == null) return false;
    return !Jwt.isExpired(token);
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final email = await _storage.read(key: 'email');
    if (email == null) return null;

    final firstName = await _storage.read(key: 'first_name') ?? '';
    final lastName = await _storage.read(key: 'last_name') ?? '';
    final role = await _storage.read(key: 'role') ?? '';
    final extraPermsStr = await _storage.read(key: 'extra_permissions');
    final extraPermissions = extraPermsStr != null
        ? List<String>.from(jsonDecode(extraPermsStr))
        : <String>[];

    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'extra_permissions': extraPermissions,
    };
  }

  // -------------------------
  // Requests autenticados
  // -------------------------
  static Future<http.Response> get(String path) async {
    final access = await _storage.read(key: 'access');
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: {
      'Authorization': 'Bearer $access',
      'Content-Type': 'application/json',
    });
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final access = await _storage.read(key: 'access');
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri,
        headers: {
          'Authorization': 'Bearer $access',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body));
  }

  // --- agrega dentro de ApiService ---

static Future<Map<String, String>> _authHeaders() async {
  final access = await _storage.read(key: 'access');
  return {
    'Authorization': 'Bearer $access',
    'Content-Type': 'application/json',
  };
}

static Future<http.Response> put(String path, Map<String, dynamic> body) async {
  final headers = await _authHeaders();
  final uri = Uri.parse('$baseUrl$path');
  return http.put(uri, headers: headers, body: jsonEncode(body));
}

static Future<http.Response> patch(String path, Map<String, dynamic> body) async {
  final headers = await _authHeaders();
  final uri = Uri.parse('$baseUrl$path');
  return http.patch(uri, headers: headers, body: jsonEncode(body));
}

static Future<http.Response> delete(String path) async {
  final headers = await _authHeaders();
  final uri = Uri.parse('$baseUrl$path');
  return http.delete(uri, headers: headers);
}

}


