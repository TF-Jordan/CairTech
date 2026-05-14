import 'package:flutter/widgets.dart';

import '../theme/colors.dart';

class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.data,
    this.height = 80,
    this.color = BbcColors.ink,
    this.fillOpacity = 0.06,
  });

  final List<double> data;
  final double height;
  final Color color;
  final double fillOpacity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext c, BoxConstraints constr) {
        final double width = constr.maxWidth;
        return CustomPaint(
          size: Size(width, height),
          painter: _SparklinePainter(
            data: data,
            color: color,
            fill: color.withOpacity(fillOpacity),
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.data, required this.color, required this.fill});

  final List<double> data;
  final Color color;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double max = data.reduce((double a, double b) => a > b ? a : b);
    final double min = data.reduce((double a, double b) => a < b ? a : b);
    final double range = (max - min) == 0 ? 1 : max - min;
    final double step = data.length > 1 ? size.width / (data.length - 1) : size.width;

    final Path line = Path();
    for (int i = 0; i < data.length; i++) {
      final double x = i * step;
      final double y = size.height - ((data[i] - min) / range) * (size.height - 8) - 4;
      if (i == 0) {
        line.moveTo(x, y);
      } else {
        line.lineTo(x, y);
      }
    }

    final Path fillPath = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, Paint()..color = fill);
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    final double lastX = (data.length - 1) * step;
    final double lastY =
        size.height - ((data.last - min) / range) * (size.height - 8) - 4;
    canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.data != data;
}
