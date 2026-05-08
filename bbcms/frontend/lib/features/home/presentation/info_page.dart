import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../publications/data/publications_repository.dart';

class InfoPage extends ConsumerWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVerses = ref.watch(dailyVersesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Bible Club'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GlassCard(
            gradient: AppColors.primaryGradient,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VISION',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white70, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CHF Bible Club',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Élever des disciples authentiques de Christ '
                  'dans chaque école et chaque profession.',
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('VERSET DU JOUR',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.textMuted, letterSpacing: 2)),
          const SizedBox(height: 8),
          asyncVerses.when(
            loading: () => const GlassCard(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => GlassCard(child: Text('$e')),
            data: (verses) {
              if (verses.isEmpty) {
                return const GlassCard(
                  child: Text('Aucun verset publié pour le moment.'),
                );
              }
              final v = verses.first;
              return GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.reference,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 8),
                    Text(v.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(v.verseText,
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, height: 1.5)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
