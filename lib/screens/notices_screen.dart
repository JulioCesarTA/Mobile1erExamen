// lib/screens/notices_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notices_service.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  bool _loading = true;
  String? _error;
  List<Notice> _items = [];
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final u = await ApiService.getCurrentUser();
    if (!mounted) return;
    setState(() => _user = u);
    await _fetch();
  }

  bool get _isAdmin {
    final r = (_user?['role'] ?? '').toString().toLowerCase();
    return r.contains('admin'); // cubre "admin" / "administrador"
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await NoticesService.list();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } on AuthError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.')),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refresh() => _fetch();

  // 👇 Solo admin puede modificar
  bool _canModify(Notice n) => _isAdmin;

  void _openCreate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NoticeFormSheet(
        onSubmit: (title, content, priority) async {
          try {
            final created = await NoticesService.create(
              title: title,
              content: content,
              priority: priority,
            );
            if (!mounted) return;
            Navigator.pop(context);
            setState(() => _items.insert(0, created));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aviso creado')),
            );
          } on AuthError {
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al crear: $e')),
            );
          }
        },
      ),
    );
  }

  void _openEdit(Notice n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => NoticeFormSheet(
        initial: n,
        onSubmit: (title, content, priority) async {
          try {
            final updated = await NoticesService.update(
              n.copyWith(title: title, content: content, priority: priority),
            );
            if (!mounted) return;
            Navigator.pop(context);
            setState(() {
              final i = _items.indexWhere((e) => e.id == updated.id);
              if (i >= 0) _items[i] = updated;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aviso actualizado')),
            );
          } on AuthError {
            if (!mounted) return;
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al actualizar: $e')),
            );
          }
        },
      ),
    );
  }

  Future<void> _delete(Notice n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar aviso'),
        content: Text('¿Seguro que deseas eliminar "${n.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await NoticesService.delete(n.id!);
      if (!mounted) return;
      setState(() => _items.removeWhere((e) => e.id == n.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aviso eliminado')),
      );
    } on AuthError {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(height: 8),
            Text('Error: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetch, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    return Scaffold(
      // 👇 FAB solo para admin
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo aviso'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final n = _items[index];
            final canEdit = _canModify(n);

            return Card(
              child: ListTile(
                leading: _PriorityBadge(priority: n.priority),
                title: Text(n.title.isEmpty ? 'Aviso #${n.id ?? '-'}' : n.title),
                subtitle: Text(
                  n.content.replaceAll('\n', ' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // ✅ FIX OVERFLOW: usar fila horizontal, no columna
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _fmtDate(n.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (canEdit) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _openEdit(n);
                          if (value == 'del') _delete(n);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(value: 'del', child: Text('Eliminar')),
                        ],
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(n.title.isEmpty ? 'Aviso' : n.title),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prioridad: ${n.priority}'),
                            const SizedBox(height: 6),
                            Text('Autor: ${n.createdBy ?? '-'}'),
                            const SizedBox(height: 12),
                            Text(n.content),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '';
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  Color _color(BuildContext context) {
    switch (priority.toUpperCase()) {
      case NoticePriority.alta:
        return Colors.redAccent;
      case NoticePriority.baja:
        return Colors.green;
      case NoticePriority.media:
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(context);
    return CircleAvatar(
      backgroundColor: c.withOpacity(0.15),
      child: Icon(Icons.campaign, color: c),
    );
  }
}

class NoticeFormSheet extends StatefulWidget {
  const NoticeFormSheet({
    super.key,
    this.initial,
    required this.onSubmit,
  });

  final Notice? initial;
  final Future<void> Function(String title, String content, String priority) onSubmit;

  @override
  State<NoticeFormSheet> createState() => _NoticeFormSheetState();
}

class _NoticeFormSheetState extends State<NoticeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.initial?.title ?? '');
  late final TextEditingController _content =
      TextEditingController(text: widget.initial?.content ?? '');
  String _priority = NoticePriority.media;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _priority = (widget.initial?.priority ?? NoticePriority.media).toUpperCase();
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSubmit(_title.text.trim(), _content.text.trim(), _priority);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(isEdit ? 'Editar aviso' : 'Nuevo aviso',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _content,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _priority,
                  isExpanded: true,
                  items: NoticePriority.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v ?? NoticePriority.media),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isEdit ? 'Guardar cambios' : 'Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
