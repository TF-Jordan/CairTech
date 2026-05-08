import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/rbac/auth_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/application/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            GlassCard(
              gradient: AppColors.primaryGradient,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session?.email ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session?.userType ?? '—',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
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
                  Text('Permissions',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('${session?.permissions.length ?? 0} actives'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Se déconnecter',
              icon: Icons.logout,
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
