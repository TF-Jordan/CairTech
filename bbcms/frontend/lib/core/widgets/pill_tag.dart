import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

enum PillKind { defaultKind, success, warn, accent, ink }

class PillTag extends StatelessWidget {
  const PillTag(this.text, {super.key, this.kind = PillKind.defaultKind, this.leading});

  final String text;
  final PillKind kind;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final ({Color bg, Color border, Color fg}) c = _tints(kind);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        border: Border.all(color: c.border),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (leading != null) ...<Widget>[
            IconTheme(data: IconThemeData(color: c.fg, size: 11), child: leading!),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: BbcTypo.mono(size: 10, color: c.fg, letterSpacing: 1).copyWith(),
          ),
        ],
      ),
    );
  }

  ({Color bg, Color border, Color fg}) _tints(PillKind k) {
    switch (k) {
      case PillKind.success:
        return (
          bg: BbcColors.tagSuccessBg,
          border: BbcColors.tagSuccessBorder,
          fg: BbcColors.positive
        );
      case PillKind.warn:
        return (
          bg: BbcColors.tagWarnBg,
          border: BbcColors.tagWarnBorder,
          fg: BbcColors.warn
        );
      case PillKind.accent:
        return (
          bg: BbcColors.accentSoft,
          border: const Color(0xFFD2DFFE),
          fg: BbcColors.accent
        );
      case PillKind.ink:
        return (bg: BbcColors.ink, border: BbcColors.ink, fg: const Color(0xFFFFFFFF));
      case PillKind.defaultKind:
        return (bg: BbcColors.hair2, border: BbcColors.hair, fg: BbcColors.ink2);
    }
  }
}

extension on TextStyle {
  TextStyle copyWith() => this;
}
