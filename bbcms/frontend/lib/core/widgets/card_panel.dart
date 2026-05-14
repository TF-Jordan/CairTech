import 'package:flutter/material.dart';

import '../theme/colors.dart';

class CardPanel extends StatelessWidget {
  const CardPanel({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.padding = const EdgeInsets.all(18),
    this.dark = false,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool dark;
  final double radius;

  @override
  Widget build(BuildContext context) => Padding(
        padding: margin,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: dark ? BbcColors.ink : BbcColors.surface,
            border: Border.all(
              color: dark ? Colors.white.withOpacity(0.1) : BbcColors.hair,
            ),
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          child: child,
        ),
      );
}
