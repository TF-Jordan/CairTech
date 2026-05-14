import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

enum AvatarSize { sm, md, lg }

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.color,
    this.size = AvatarSize.md,
    this.imageUrl,
  });

  final String name;
  final Color? color;
  final AvatarSize size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final double d = _dim(size);
    final String initials = _initials(name);
    final Color bg = color ?? BbcColors.ink;
    final Widget child = imageUrl != null && imageUrl!.isNotEmpty
        ? ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl!,
              width: d,
              height: d,
              fit: BoxFit.cover,
              placeholder: (_, __) => _fallback(bg, initials, d),
              errorWidget: (_, __, ___) => _fallback(bg, initials, d),
            ),
          )
        : _fallback(bg, initials, d);
    return child;
  }

  Widget _fallback(Color bg, String text, double d) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          text,
          style: BbcTypo.sans(
            size: size == AvatarSize.lg
                ? 22
                : size == AvatarSize.sm
                    ? 11
                    : 14,
            weight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
      );

  double _dim(AvatarSize s) {
    switch (s) {
      case AvatarSize.sm:
        return 28;
      case AvatarSize.lg:
        return 64;
      case AvatarSize.md:
        return 40;
    }
  }

  String _initials(String n) {
    final List<String> parts = n.trim().split(RegExp(r'\s+')).take(2).toList();
    return parts.map((String p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }
}
