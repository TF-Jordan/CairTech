import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class ChipSelector extends StatelessWidget {
  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          for (final String o in options) ...<Widget>[
            _Chip(
              label: o,
              active: o == selected,
              onTap: () => onChanged(o),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? BbcColors.ink : BbcColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: active ? BbcColors.ink : BbcColors.hair),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: BbcTypo.sans(
              size: 12,
              weight: FontWeight.w500,
              color: active ? Colors.white : BbcColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}
