import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.message, this.action});

  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.inbox_outlined, size: 36, color: BbcColors.muted2),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: BbcTypo.sans(size: 14, weight: FontWeight.w500)),
              if (message != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(message!,
                    textAlign: TextAlign.center,
                    style: BbcTypo.meta(color: BbcColors.muted)),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: 16),
                action!,
              ],
            ],
          ),
        ),
      );
}
