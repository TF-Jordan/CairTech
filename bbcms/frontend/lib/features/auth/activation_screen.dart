import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/widgets/primary_button.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key, required this.token});

  final String? token;

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  bool _busy = false;
  String? _error;
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) _activate();
  }

  Future<void> _activate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).activateAccount(widget.token!);
      if (mounted) setState(() => _ok = true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Erreur réseau');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: BbcColors.bg,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_busy) ...<Widget>[
                    const CircularProgressIndicator(color: BbcColors.ink),
                    const SizedBox(height: 16),
                    Text('Activation en cours…', style: BbcTypo.meta()),
                  ] else if (_ok) ...<Widget>[
                    const Icon(Icons.check_circle_outline,
                        size: 48, color: BbcColors.positive),
                    const SizedBox(height: 16),
                    Text('Compte activé',
                        style: BbcTypo.serif(size: 28, height: 1.1)),
                    const SizedBox(height: 8),
                    Text('Vous pouvez maintenant vous connecter.',
                        style: BbcTypo.meta()),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Se connecter',
                      onPressed: () => context.go('/login'),
                    ),
                  ] else if (_error != null) ...<Widget>[
                    const Icon(Icons.error_outline,
                        size: 48, color: BbcColors.danger),
                    const SizedBox(height: 16),
                    Text('Échec d\'activation',
                        style: BbcTypo.serif(size: 24, height: 1.1)),
                    const SizedBox(height: 8),
                    Text(_error!,
                        textAlign: TextAlign.center, style: BbcTypo.meta()),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Retour',
                      style: BbcButtonStyle.ghost,
                      onPressed: () => context.go('/login'),
                    ),
                  ] else ...<Widget>[
                    Text('Aucun token d\'activation fourni',
                        style: BbcTypo.meta()),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}
