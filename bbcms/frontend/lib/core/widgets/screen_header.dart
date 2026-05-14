import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.dense = false,
    this.dark = false,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool dense;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color fg = dark ? const Color(0xFFFFFFFF) : BbcColors.ink;
    final Color muted = dark ? const Color(0xFFFFFFFF).withOpacity(0.55) : BbcColors.muted;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, dense ? 14 : 18, 20, dense ? 10 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (eyebrow != null)
                  Text(eyebrow!.toUpperCase(), style: BbcTypo.eyebrow(color: muted)),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: BbcTypo.sans(
                    size: dense ? 17 : 22,
                    weight: dense ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                    letterSpacing: -0.33,
                    height: 1.15,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: BbcTypo.sans(size: 12, color: muted, weight: FontWeight.w400)),
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Row(
              children: <Widget>[
                for (int i = 0; i < actions.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: 6),
                  actions[i],
                ],
              ],
            ),
        ],
      ),
    );
  }
}
