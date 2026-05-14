import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
    this.suffix,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label.toUpperCase(),
            style: BbcTypo.mono(size: 10, color: BbcColors.muted)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Icon(icon, size: 16, color: BbcColors.muted),
                  ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 18),
            suffixIcon: suffix,
          ),
          style: BbcTypo.sans(size: 15, color: BbcColors.ink),
        ),
      ],
    );
  }
}
