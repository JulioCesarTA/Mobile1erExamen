import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});
  final Map<String, dynamic>? user;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final email = (user?['email'] ?? '').toString();
    final role  = (user?['role']  ?? '').toString();

    // Permisos como lista de strings
    final List<String> extraPermissions =
        ((user?['extra_permissions'] as List?) ?? [])
            .map((e) => e.toString())
            .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con avatar + emails
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cs.primary.withOpacity(.12),
                      child: Icon(Icons.person, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Primera línea (email en negrita)
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          // Segunda línea (email pequeño / gris)
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium,
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                // Rol
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rol: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(role.isEmpty ? '—' : role),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Permisos
                const Text(
                  'Permisos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (extraPermissions.isEmpty)
                  Text('—', style: TextStyle(color: cs.onSurfaceVariant))
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: extraPermissions.map((p) {
                      return Chip(
                        label: Text(p),
                        backgroundColor:
                            cs.surfaceContainerHighest.withOpacity(.4),
                        side: BorderSide(color: cs.outlineVariant, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
