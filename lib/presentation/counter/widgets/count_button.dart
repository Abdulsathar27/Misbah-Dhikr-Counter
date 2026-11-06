import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import 'disc_button.dart';
import 'line_icons.dart';

/// The round fingerprint button that counts. Each press sends a ripple out
/// from the touch point. It stays stateful only to own the ripple animation.
class CountButton extends StatefulWidget {
  const CountButton({super.key, required this.semanticLabel, required this.onPressed});

  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  State<CountButton> createState() => _CountButtonState();
}

class _CountButtonState extends State<CountButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: AppMotion.ripple,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _ripple,
    curve: AppMotion.rippleCurve,
  );
  Offset _origin = Offset.zero;

  /// Every press restarts the ripple; skipped when reduced motion is on.
  void _startRipple(Offset origin) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return;
    _origin = origin;
    _ripple.forward(from: 0);
  }

  @override
  void dispose() {
    _ripple.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DiscButton(
      size: AppDimensions.countButtonSize,
      semanticLabel: widget.semanticLabel,
      onPressed: widget.onPressed,
      onPressStart: _startRipple,
      child: ClipOval(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _RipplePainter(_progress, () => _origin),
            child: const Center(
              child: LineIcon(
                LineIconGlyph.fingerprint,
                color: AppColors.accent,
                size: AppDimensions.countButtonIconSize,
                strokeWidth: AppDimensions.countButtonIconStroke,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A circle that grows from the touch point until it covers the disc, fading out.
class _RipplePainter extends CustomPainter {
  _RipplePainter(this.progress, this.origin) : super(repaint: progress);

  final Animation<double> progress;
  final Offset Function() origin;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t == 0 || t == 1) return;
    final from = origin();
    // Far enough to reach the opposite edge from any touch point.
    final maxRadius = (size.center(Offset.zero) - from).distance + size.shortestSide / 2;
    final alpha = AppColors.ripple.a * (1 - t);
    canvas.drawCircle(
      from,
      maxRadius * t,
      Paint()..color = AppColors.ripple.withValues(alpha: alpha),
    );
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) => false;
}
