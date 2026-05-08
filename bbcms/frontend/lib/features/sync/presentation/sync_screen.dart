import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/sync/sync_engine.dart';
import '../../../core/sync/sync_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  bool _running = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    final asyncEngine = ref.watch(syncEngineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Synchronisation')),
      body: asyncEngine.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (engine) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              color: AppColors.surfaceAlt,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Device',
                      style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    engine.deviceId,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Curseurs locaux',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (final kind in SyncEntityKind.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(kind.apiValue,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(
                            engine
                                    .cursorOf(kind)
                                    ?.toIso8601String()
                                    .substring(0, 19) ??
                                '—',
                            style:
                                const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Synchroniser maintenant',
              icon: Icons.sync,
              loading: _running,
              onPressed: () async {
                setState(() {
                  _running = true;
                  _result = null;
                });
                try {
                  final n = await engine.pullAll();
                  setState(() => _result = '$n changements téléchargés.');
                } catch (e) {
                  setState(() => _result = 'Erreur: $e');
                } finally {
                  if (mounted) setState(() => _running = false);
                }
              },
            ),
            if (_result != null) ...[
              const SizedBox(height: 12),
              Text(_result!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
