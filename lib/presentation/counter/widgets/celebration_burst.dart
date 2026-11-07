import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// The lamp lighting: a soft gold glow with rays of light flying outward.
/// Decorative only. [rays] and [glow] each run 0 to 1.
class CelebrationBurst extends StatelessWidget {
  const CelebrationBurst({super.key, required this.rays, required this.glow});

  final Animation<double> rays;
  final Animation<double> glow;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _BurstPainter(rays: rays, glow: glow),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Ray {
  const _Ray({
    required this.angle,
    required this.delay,
    required this.reach,
    required this.length,
    required this.width,
    required this.color,
  });

  final double angle;

  /// Share of the burst to wait before this ray sets off.
  final double delay;

  /// How far out it flies, as a share of the available radius.
  final double reach;
  final double length;
  final double width;
  final Color color;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.rays, required this.glow})
    : super(repaint: Listenable.merge([rays, glow]));

  final Animation<double> rays;
  final Animation<double> glow;

  /// Seeded so the burst looks the same every time.
  static final List<_Ray> _rays = () {
    final random = math.Random(11);
    const count = 26;
    return [
      for (var i = 0; i < count; i++)
        _Ray(
          angle: (i + random.nextDouble() * 0.7) / count * 2 * math.pi,
          delay: random.nextDouble() * 0.4,
          reach: 0.55 + random.nextDouble() * 0.45,
          length: 14 + random.nextDouble() * 34,
          width: 1.5 + random.nextDouble() * 1.5,
          color: i.isEven ? AppColors.lampGold : AppColors.cream,
        ),
    ];
  }();

  static const double _startRadius = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    if (glow.value > 0) {
      final rect = Rect.fromCircle(center: centre, radius: radius);
      canvas.drawCircle(
        centre,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.lampGold.withValues(alpha: 0.42 * glow.value),
              AppColors.lampGold.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }

    final paint = Paint()..strokeCap = StrokeCap.round;
    for (final ray in _rays) {
      final local = ((rays.value - ray.delay) / (1 - ray.delay)).clamp(0.0, 1.0);
      if (local == 0 || local == 1) continue;
      final eased = Curves.easeOutCubic.transform(local);
      final distance = _startRadius + (radius * ray.reach - _startRadius) * eased;
      final direction = Offset(math.cos(ray.angle), math.sin(ray.angle));
      canvas.drawLine(
        centre + direction * distance,
        centre + direction * (distance + ray.length * (1 - local * 0.6)),
        paint
          ..strokeWidth = ray.width
          ..color = ray.color.withValues(alpha: 1 - local),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => false;
}
