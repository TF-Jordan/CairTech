import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

enum BbcButtonStyle { primary, ghost, danger }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = BbcButtonStyle.primary,
    this.trailing,
    this.expand = true,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BbcButtonStyle style;
  final Widget? trailing;
  final bool expand;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = style == BbcButtonStyle.primary;
    final bool isDanger = style == BbcButtonStyle.danger;
    final Color bg = isPrimary ? BbcColors.ink : Colors.transparent;
    final Color fg = isPrimary
        ? Colors.white
        : isDanger
            ? BbcColors.danger
            : BbcColors.ink;
    final BorderSide border = BorderSide(
      color: isPrimary ? BbcColors.ink : BbcColors.hair,
    );
    final Widget content = busy
        ? const SizedBox(
            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(label,
                  style: BbcTypo.sans(size: 14, weight: FontWeight.w500, color: fg)),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                IconTheme(data: IconThemeData(size: 14, color: fg), child: trailing!),
              ],
            ],
          );

    final Widget btn = Material(
      color: bg,
      shape: RoundedRectangleBorder(
        side: border,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        onTap: busy ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: content,
        ),
      ),
    );
    if (!expand) return btn;
    return SizedBox(width: double.infinity, child: btn);
  }
}
