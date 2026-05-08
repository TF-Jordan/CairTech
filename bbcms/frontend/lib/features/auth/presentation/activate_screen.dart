import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/error/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/auth_controller.dart';
import '../domain/auth_models.dart';

class ActivateScreen extends ConsumerStatefulWidget {
  const ActivateScreen({required this.token, super.key});
  final String token;

  @override
  ConsumerState<ActivateScreen> createState() => _ActivateScreenState();
}

class _ActivateScreenState extends ConsumerState<ActivateScreen> {
  late Future<UserAccount> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(authControllerProvider.notifier).activate(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<UserAccount>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snap.hasError) {
              final err = snap.error;
              final msg = err is AppFailure
                  ? err.message
                  : 'Erreur lors de l\'activation';
              return _Status(
                ok: false,
                message: msg,
                onContinue: () => context.go(AppRoutes.login),
              );
            }
            return _Status(
              ok: true,
              message: 'Compte activé. Vous pouvez vous connecter.',
              onContinue: () => context.go(AppRoutes.login),
            );
          },
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({
    required this.ok,
    required this.message,
    required this.onContinue,
  });
  final bool ok;
  final String message;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_rounded,
            size: 80,
            color: ok ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continuer',
            expand: false,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
