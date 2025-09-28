import 'package:flutter/material.dart';
import '../../models/notice.dart';
import '../../services/notices_service.dart';
import '../../widgets/skeleton_tile.dart';
import '../../widgets/empty_state.dart';
import 'notice_detail_screen.dart';

class NoticesListScreen extends StatefulWidget {
  const NoticesListScreen({super.key});

  @override
  State<NoticesListScreen> createState() => _NoticesListScreenState();
}

class _NoticesListScreenState extends State<NoticesListScreen> {
  late Future<List<Notice>> _future;

  @override
  void initState() {
    super.initState();
    _future = NoticesService.listNotices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Notice>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: 6,
            itemBuilder: (_, __) => const SkeletonTile(),
          );
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const EmptyState(
            title: "Sin avisos aún",
            subtitle:
                "Cuando la administración publique avisos aparecerán aquí.",
            icon: Icons.campaign_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final n = items[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: Text(n.title),
                subtitle: Text(n.createdAt.toString()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoticeDetailScreen(noticeId: n.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
