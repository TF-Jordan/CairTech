import 'package:flutter/material.dart';

import '../theme/colors.dart';

class RoundIcon extends StatelessWidget {
  const RoundIcon({
    super.key,
    required this.icon,
    this.size = 36,
    this.dark = false,
    this.onTap,
  });

  final IconData icon;
  final double size;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.04) : BbcColors.surface,
        border: Border.all(
          color: dark ? Colors.white.withOpacity(0.16) : BbcColors.hair,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Icon(
        icon,
        size: size * 0.4,
        color: dark ? Colors.white.withOpacity(0.85) : BbcColors.ink,
      ),
    );
    if (onTap == null) return box;
    return InkResponse(onTap: onTap, radius: size, child: box);
  }
}
