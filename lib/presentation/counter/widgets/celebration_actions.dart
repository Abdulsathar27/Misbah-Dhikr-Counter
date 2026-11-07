import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';

/// The two choices after reaching a goal: set a new one, or carry on without.
class CelebrationActions extends StatelessWidget {
  const CelebrationActions({super.key, required this.onSetNewGoal, required this.onContinue});

  final VoidCallback onSetNewGoal;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A darker lip under the pill gives the button a raised, tactile edge.
        DecoratedBox(
          decoration: const ShapeDecoration(
            shape: StadiumBorder(),
            shadows: [BoxShadow(color: AppColors.lampGoldShade, offset: Offset(0, 4))],
          ),
          child: FilledButton(
            onPressed: onSetNewGoal,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              minimumSize: const Size.fromHeight(AppDimensions.celebrationButtonHeight),
              shape: const StadiumBorder(),
              textStyle: AppTypography.celebrationButton,
            ),
            child: const Text('Set new goal'),
          ),
        ),
        const SizedBox(height: AppDimensions.celebrationTextGap),
        TextButton(
          onPressed: onContinue,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.foreground,
            textStyle: AppTypography.celebrationButton,
          ),
          child: const Text('Continue without goal'),
        ),
      ],
    );
  }
}
