import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/discipleship_repository.dart';

class DiscipleshipScreen extends ConsumerStatefulWidget {
  const DiscipleshipScreen({super.key});

  @override
  ConsumerState<DiscipleshipScreen> createState() =>
      _DiscipleshipScreenState();
}

class _DiscipleshipScreenState extends ConsumerState<DiscipleshipScreen> {
  final _maker = TextEditingController();
  Future<List<DiscipleLink>>? _future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discipleship')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Disciples d\'un disciple-maker',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _maker,
                  decoration: const InputDecoration(
                    labelText: 'Maker member ID',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Charger'),
                  onPressed: () => setState(() {
                    _future = ref
                        .read(discipleshipRepositoryProvider)
                        .linksOf(_maker.text.trim());
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_future != null)
            FutureBuilder<List<DiscipleLink>>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final links = snap.data!;
                return Column(
                  children: links
                      .map(
                        (l) => GlassCard(
                          padding: const EdgeInsets.all(14),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.link,
                                color: AppColors.primary),
                            title: Text(l.discipleId),
                            subtitle: Text(
                              l.active ? 'Actif' : 'Terminé',
                              style: TextStyle(
                                color: l.active
                                    ? AppColors.success
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
