import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

/// The splash emblem, built in the proportions of the logo: a gold ring that
/// draws itself clockwise, then the emerald disc and the Arabic word settling
/// in at its centre. [progress] runs 0 to 1.
class SplashMark extends StatelessWidget {
  const SplashMark({super.key, required this.progress});

  /// The word مصباح in cream with true transparency, cut from the logo. The
  /// image is the disc's full square, so the word keeps its place in the disc.
  static const AssetImage word = AssetImage('assets/logo/misbah_word.png');

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppDimensions.splashMarkSize,
      child: CustomPaint(
        painter: _RingPainter(progress),
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: progress, curve: const Interval(0.4, 1)),
            child: ScaleTransition(
              scale: Tween(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(
                  parent: progress,
                  curve: const Interval(0.4, 1, curve: Curves.easeOutBack),
                ),
              ),
              child: const SizedBox.square(
                dimension: AppDimensions.splashMarkDiscSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle),
                  // The wordmark below the emblem already names the app.
                  child: Image(image: word, filterQuality: FilterQuality.high, excludeFromSemantics: true),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress) : super(repaint: progress);

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
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
