import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/rbac/permissions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/perm_gate.dart';

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réunions')),
      floatingActionButton: PermGate(
        perm: Perm.meetingPlan,
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => context.push('/meetings/new'),
          icon: const Icon(Icons.add),
          label: const Text('Planifier'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            color: AppColors.surfaceAlt,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cycle de réunions',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                SizedBox(height: 6),
                Text(
                  'Planifier · Démarrer · Présence · Enregistrer',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Démarrer rapide',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_circle, color: AppColors.primary),
                  title: const Text('Planifier une réunion'),
                  onTap: () => context.push('/meetings/new'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history),
                  title: const Text('Coller un ID pour ouvrir une réunion'),
                  onTap: () => _open(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final c = TextEditingController();
    final id = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ouvrir une réunion'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Meeting ID (UUID)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, c.text.trim()),
            child: const Text('Ouvrir'),
          ),
        ],
      ),
    );
    if (id != null && id.isNotEmpty && context.mounted) {
      context.push('/meetings/$id');
    }
  }
}
