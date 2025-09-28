import 'dart:async';
import '../models/notice.dart';
import 'api_service.dart';

class NoticesService {
  static Future<List<Notice>> listNotices() async {
    // final resp = await ApiService.get('/api/notices/');
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(
      5,
      (i) => Notice(
        id: '$i',
        title: 'Aviso importante #${i + 1}',
        body: 'Reunión de copropietarios el viernes a las 19:00.',
        createdAt: DateTime.now().subtract(Duration(days: i)),
      ),
    );
  }

  static Future<Notice> getNotice(String id) async {
    // final resp = await ApiService.get('/api/notices/$id/');
    await Future.delayed(const Duration(milliseconds: 200));
    return Notice(
      id: id,
      title: 'Aviso $id',
      body: 'Detalle del aviso $id',
      createdAt: DateTime.now(),
    );
  }
}
