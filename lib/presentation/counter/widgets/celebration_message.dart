import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';

/// "Goal complete!" and the goal that was reached, announced to screen readers.
class CelebrationMessage extends StatelessWidget {
  const CelebrationMessage({super.key, required this.goal});

  final int goal;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          liveRegion: true,
          child: const Text('Goal complete!', style: AppTypography.celebrationTitle),
        ),
        const SizedBox(height: AppDimensions.splashTaglineGap),
        Text('You reached your goal of $goal', style: AppTypography.tagline),
      ],
    );
  }
}
