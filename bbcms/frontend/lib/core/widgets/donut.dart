import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/colors.dart';

class Donut extends StatelessWidget {
  const Donut({
    super.key,
    required this.value,
    this.size = 120,
    this.stroke = 8,
    this.color = BbcColors.ink,
    this.track = BbcColors.hair,
    this.child,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color track;
  final Widget? child;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CustomPaint(
              size: Size(size, size),
              painter: _DonutPainter(
                value: value.clamp(0.0, 1.0),
                stroke: stroke,
                color: color,
                track: track,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      );
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.track,
  });

  final double value;
  final double stroke;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final double r = (size.shortestSide - stroke) / 2;
    final Offset c = Offset(size.width / 2, size.height / 2);
    final Paint trackPaint = Paint()
      ..color = track
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    final Paint progPaint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, trackPaint);
    final Rect rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(rect, -math.pi / 2, value * 2 * math.pi, false, progPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.value != value || old.color != color;
}
