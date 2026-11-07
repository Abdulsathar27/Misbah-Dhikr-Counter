import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';

/// The number rolling up from 0 to [goal] as [animation] runs 0 to 1.
class CelebrationCountUp extends StatelessWidget {
  const CelebrationCountUp({super.key, required this.goal, required this.animation});

  final int goal;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder:
          (context, _) => Text(
            '${(goal * animation.value).round()}',
            maxLines: 1,
            style: AppTypography.celebrationCount,
            textScaler: TextScaler.noScaling,
          ),
    );
  }
}
