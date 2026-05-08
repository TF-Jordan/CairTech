import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/publications_repository.dart';

class PublicationsScreen extends ConsumerWidget {
  const PublicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Publications'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Versets du jour', icon: Icon(Icons.menu_book)),
              Tab(text: 'Annonces', icon: Icon(Icons.campaign_outlined)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_VersesTab(), _AnnouncementsTab()],
        ),
      ),
    );
  }
}

class _VersesTab extends ConsumerWidget {
  const _VersesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVerses = ref.watch(dailyVersesProvider);
    return asyncVerses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (verses) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(dailyVersesProvider),
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: verses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final v = verses[i];
            return GlassCard(
              color: i == 0 ? AppColors.surfaceAlt : AppColors.surface,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.reference,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(v.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    v.verseText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                      height: 1.55,
                    ),
                  ),
                  if (v.reflectionText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      v.reflectionText!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnnouncementsTab extends ConsumerWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnn = ref.watch(announcementsProvider);
    return asyncAnn.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (anns) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(announcementsProvider),
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: anns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final a = anns[i];
            final color = a.type == 'URGENT'
                ? AppColors.danger
                : a.type == 'IMPORTANT'
                    ? AppColors.warning
                    : AppColors.primary;
            return GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      a.type,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(a.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(a.content),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
