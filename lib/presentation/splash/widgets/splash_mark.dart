import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../counter/widgets/line_icons.dart';

/// The splash emblem: a ring that draws itself clockwise around the
/// fingerprint, echoing the counter's progress ring. [progress] runs 0 to 1.
class SplashMark extends StatelessWidget {
  const SplashMark({super.key, required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppDimensions.splashMarkSize,
      child: CustomPaint(
        painter: _MarkPainter(progress),
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: progress, curve: const Interval(0.4, 1)),
            child: ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.0).animate(
                CurvedAnimation(
                  parent: progress,
                  curve: const Interval(0.4, 1, curve: Curves.easeOutBack),
                ),
              ),
              child: const LineIcon(
                LineIconGlyph.fingerprint,
                color: AppColors.foreground,
                size: AppDimensions.splashMarkIconSize,
                strokeWidth: AppDimensions.countButtonIconStroke,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = AppDimensions.splashMarkStroke;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke;
    canvas.drawOval(rect, paint..color = AppColors.ringTrack);

    final sweep = progress.value.clamp(0.0, 1.0) * 2 * math.pi;
    if (sweep <= 0) return;
    paint
      ..color = AppColors.ringProgress
      ..strokeCap = sweep >= 2 * math.pi ? StrokeCap.butt : StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.progress != progress;
}
