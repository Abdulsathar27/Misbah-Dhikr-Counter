import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../splash/widgets/splash_mark.dart';
import 'celebration_burst.dart';

/// The burst with the spark at its centre, and the emblem that grows from it.
class CelebrationEmblem extends StatelessWidget {
  const CelebrationEmblem({
    super.key,
    required this.spark,
    required this.sparkFade,
    required this.rays,
    required this.glow,
    required this.emblem,
    required this.emblemScale,
  });

  final Animation<double> spark;
  final Animation<double> sparkFade;
  final Animation<double> rays;
  final Animation<double> glow;
  final Animation<double> emblem;
  final Animation<double> emblemScale;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppDimensions.celebrationStageSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CelebrationBurst(rays: rays, glow: glow)),
          ScaleTransition(
            scale: Tween(begin: 0.3, end: AppDimensions.celebrationEmblemScale).animate(emblemScale),
            child: FadeTransition(opacity: emblem, child: SplashMark(progress: emblem)),
          ),
          FadeTransition(
            opacity: sparkFade,
            child: ScaleTransition(scale: spark, child: const _Spark()),
          ),
        ],
      ),
    );
  }
}

/// The small glowing gold orb the burst starts from.
class _Spark extends StatelessWidget {
  const _Spark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: AppDimensions.celebrationSparkSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.35),
            colors: [AppColors.cream, AppColors.lampGold],
          ),
          boxShadow: [BoxShadow(color: AppColors.lampGold, blurRadius: 28, spreadRadius: 4)],
        ),
      ),
    );
  }
}
