import 'package:flutter/widgets.dart';

import '../../../app/theme/app_dimensions.dart';

/// The reference's line icons (tabler refresh, lucide
/// vibrate / vibrate-off, tabler fingerprint, tabler target), drawn from their 24×24 SVG
/// paths so the stroke style matches exactly without an SVG dependency.
enum LineIconGlyph { reset, vibrate, vibrateOff, fingerprint, target }

class LineIcon extends StatelessWidget {
  const LineIcon(
    this.glyph, {
    super.key,
    required this.color,
    this.size = AppDimensions.controlIconSize,
    this.strokeWidth = AppDimensions.controlIconStroke,
  });

  final LineIconGlyph glyph;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LineIconPainter(glyph: glyph, color: color, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _LineIconPainter extends CustomPainter {
  _LineIconPainter({required this.glyph, required this.color, required this.strokeWidth});

  static const double _viewBox = 24;

  final LineIconGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _viewBox;
    canvas.scale(scale);
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;
    canvas.drawPath(_pathFor(glyph), paint);
  }

  static Path _pathFor(LineIconGlyph glyph) => switch (glyph) {
    LineIconGlyph.reset => _reset,
    LineIconGlyph.vibrate => _vibrate,
    LineIconGlyph.vibrateOff => _vibrateOff,
    LineIconGlyph.fingerprint => _fingerprint,
    LineIconGlyph.target => _target,
  };

  // M20 11A8.1 8.1 0 0 0 4.5 9 · M4 5v4h4 · m-4 4a8.1 8.1 0 0 0 15.5 2 · m.5 4v-4h-4
  static final Path _reset =
      Path()
        ..moveTo(20, 11)
        ..arcToPoint(const Offset(4.5, 9), radius: const Radius.circular(8.1), clockwise: false)
        ..moveTo(4, 5)
        ..lineTo(4, 9)
        ..lineTo(8, 9)
        ..moveTo(4, 13)
        ..arcToPoint(const Offset(19.5, 15), radius: const Radius.circular(8.1), clockwise: false)
        ..moveTo(20, 19)
        ..lineTo(20, 15)
        ..lineTo(16, 15);

  static Path _zigzags() =>
      Path()
        ..moveTo(2, 8)
        ..lineTo(4, 10)
        ..lineTo(2, 12)
        ..lineTo(4, 14)
        ..lineTo(2, 16)
        ..moveTo(22, 8)
        ..lineTo(20, 10)
        ..lineTo(22, 12)
        ..lineTo(20, 14)
        ..lineTo(22, 16);

  // zigzags · rect x8 y5 w8 h14 rx1
  static final Path _vibrate =
      _zigzags()..addRRect(RRect.fromLTRBR(8, 5, 16, 19, const Radius.circular(1)));

  // zigzags · M8 8v10c0 .55.45 1 1 1h6c.55 0 1-.45 1-1v-2
  // · M16 10.34V6c0-.55-.45-1-1-1h-4.34 · m2 2 20 20
  static final Path _vibrateOff =
      _zigzags()
        ..moveTo(8, 8)
        ..lineTo(8, 18)
        ..arcToPoint(const Offset(9, 19), radius: const Radius.circular(1), clockwise: false)
        ..lineTo(15, 19)
        ..arcToPoint(const Offset(16, 18), radius: const Radius.circular(1), clockwise: false)
        ..lineTo(16, 16)
        ..moveTo(16, 10.34)
        ..lineTo(16, 6)
        ..arcToPoint(const Offset(15, 5), radius: const Radius.circular(1), clockwise: false)
        ..lineTo(10.66, 5)
        ..moveTo(2, 2)
        ..lineTo(22, 22);

  // M18.9 7a8 8 0 0 1 1.1 5v1a6 6 0 0 0 .8 3 · M8 11a4 4 0 0 1 8 0v1a10 10 0 0 0 2 6
  // · M12 11v2a14 14 0 0 0 2.5 8 · M8 15a18 18 0 0 0 1.8 6
  // · M4.9 19a22 22 0 0 1 -.9 -7v-1a8 8 0 0 1 12 -6.95
  static final Path _fingerprint =
      Path()
        ..moveTo(18.9, 7)
        ..arcToPoint(const Offset(20, 12), radius: const Radius.circular(8))
        ..lineTo(20, 13)
        ..arcToPoint(const Offset(20.8, 16), radius: const Radius.circular(6), clockwise: false)
        ..moveTo(8, 11)
        ..arcToPoint(const Offset(16, 11), radius: const Radius.circular(4))
        ..lineTo(16, 12)
        ..arcToPoint(const Offset(18, 18), radius: const Radius.circular(10), clockwise: false)
        ..moveTo(12, 11)
        ..lineTo(12, 13)
        ..arcToPoint(const Offset(14.5, 21), radius: const Radius.circular(14), clockwise: false)
        ..moveTo(8, 15)
        ..arcToPoint(const Offset(9.8, 21), radius: const Radius.circular(18), clockwise: false)
        ..moveTo(4.9, 19)
        ..arcToPoint(const Offset(4, 12), radius: const Radius.circular(22))
        ..lineTo(4, 11)
        ..arcToPoint(const Offset(16, 4.05), radius: const Radius.circular(8));

  // circle r1 · circle r5 · circle r9, all at 12 12
  static final Path _target =
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 1))
        ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 5))
        ..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 9));

  @override
  bool shouldRepaint(_LineIconPainter oldDelegate) =>
      oldDelegate.glyph != glyph ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
