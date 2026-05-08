import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Refined surface card — pure white, hairline border, no glow.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.color,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(16);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? (color ?? AppColors.surface) : null,
            borderRadius: shape,
            border: Border.all(color: AppColors.border),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
