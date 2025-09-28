import 'package:flutter/material.dart';
import '../../models/notice.dart';
import '../../services/notices_service.dart';

class NoticeDetailScreen extends StatefulWidget {
  final String noticeId;
  const NoticeDetailScreen({super.key, required this.noticeId});

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  late Future<Notice> _future;

  @override
  void initState() {
    super.initState();
    _future = NoticesService.getNotice(widget.noticeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del aviso")),
      body: FutureBuilder<Notice>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final n = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      n.createdAt.toString(),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const Divider(height: 24),
                    Text(n.body),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
