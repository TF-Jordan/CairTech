import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: BbcTypo.eyebrow(color: color ?? BbcColors.muted));
}
