import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';

/// The count inside a ring that fills towards the goal. Display-only;
/// counting is done by the fingerprint button.
///
/// The ring fills from empty at launch and eases to each new [progress], the
/// count rolls up to its new value, and the label cross-fades, brightening
/// once the goal is reached. All of it is skipped when the
/// platform asks for reduced motion.
class GoalRing extends StatelessWidget {
  const GoalRing({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    required this.reached,
    required this.semanticLabel,
  });

  final String value;

  /// Shown under the count, e.g. "3 to go" or "goal reached". Empty for none.
  final String label;

  /// How full the ring is, from 0 to 1.
  final double progress;

  final bool reached;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final swap = AppMotion.of(context, AppMotion.swap);
    final labelView = AnimatedDefaultTextStyle(
      duration: swap,
      style: AppTypography.ringLabel.copyWith(
        color: reached ? AppColors.accent : AppColors.secondary,
      ),
      child: AnimatedSwitcher(
        duration: swap,
        child:
            label.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                  key: ValueKey(label),
                  padding: const EdgeInsets.only(top: AppDimensions.ringLabelGap),
                  child: _FittedText(label, null),
                ),
      ),
    );
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppDimensions.ringDiameter,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: AppMotion.of(context, AppMotion.ring),
          curve: AppMotion.ringCurve,
          builder:
              (context, animated, child) =>
                  CustomPaint(painter: _RingPainter(animated), child: child),
          child: Center(
            child: SizedBox(
              width: AppDimensions.ringContentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: swap,
                    transitionBuilder: _rollUp,
                    child: _FittedText(value, AppTypography.count, key: ValueKey(value)),
                  ),
                  // Without a label the space closes, so the count sits centred.
                  // AnimatedSize cannot run with the zero duration of reduced motion.
                  if (swap == Duration.zero)
                    labelView
                  else
                    AnimatedSize(duration: swap, child: labelView),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The new value rises into place as the old one fades.
  static Widget _rollUp(Widget child, Animation<double> animation) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation),
      child: child,
    ),
  );
}

/// One line that shrinks to fit inside the ring.
class _FittedText extends StatelessWidget {
  const _FittedText(this.text, this.style, {super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, style: style, textScaler: TextScaler.noScaling),
  );
}

/// A dim full track with the progress arc on top, starting at 12 o'clock and
/// running clockwise.
class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = AppDimensions.ringStroke;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke;

    canvas.drawOval(rect, paint..color = AppColors.ringTrack);

    final sweep = progress.clamp(0.0, 1.0) * 2 * math.pi;
    if (sweep <= 0) return;
    paint
      ..color = AppColors.ringProgress
      // A full ring has no ends, so round caps only matter part-way.
      ..strokeCap = sweep >= 2 * math.pi ? StrokeCap.butt : StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
