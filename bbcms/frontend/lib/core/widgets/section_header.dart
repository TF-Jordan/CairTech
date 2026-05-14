import 'package:flutter/widgets.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.more});

  final String title;
  final String? more;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: BbcTypo.sans(
                    size: 13, weight: FontWeight.w600, letterSpacing: -0.07),
              ),
            ),
            if (more != null)
              Text(more!.toUpperCase(),
                  style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
          ],
        ),
      );
}
