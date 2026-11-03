import 'package:flutter/material.dart';

class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double dash;
  final double gap;

  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.radius = 12,
    this.dash = 5,
    this.gap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPainter(color, radius, dash, gap),
      child: child,
    );
  }
}

class _DashedPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dash;
  final double gap;
  _DashedPainter(this.color, this.radius, this.dash, this.gap);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter old) =>
      old.color != color || old.radius != radius;
}