import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class StandbyScreen extends StatelessWidget {
  const StandbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.lock_outline,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Vision of the Bible Club',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Vous n\'êtes pas encore membre du Bible Club. '
                'Contactez un leader pour vous ajouter à l\'application.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
