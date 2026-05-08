import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/intercession_repository.dart';

class IntercessionScreen extends ConsumerStatefulWidget {
  const IntercessionScreen({super.key});

  @override
  ConsumerState<IntercessionScreen> createState() =>
      _IntercessionScreenState();
}

class _IntercessionScreenState extends ConsumerState<IntercessionScreen> {
  final _bibleClubId = TextEditingController();
  Future<List<PrayerChain>>? _future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intercession')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Chaînes de prière',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _bibleClubId,
                  decoration:
                      const InputDecoration(labelText: 'Bible Club ID'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('Charger'),
                  onPressed: () => setState(() {
                    _future = ref
                        .read(intercessionRepositoryProvider)
                        .chainsByBibleClub(_bibleClubId.text.trim());
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_future != null)
            FutureBuilder<List<PrayerChain>>(
              future: _future,
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: snap.data!
                      .map((c) => GlassCard(
                            padding: const EdgeInsets.all(14),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.favorite,
                                  color: AppColors.primary),
                              title: Text(c.title),
                              subtitle: Text(
                                '${c.status} • ${c.dateStart?.toIso8601String().substring(0, 10) ?? ''}',
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
