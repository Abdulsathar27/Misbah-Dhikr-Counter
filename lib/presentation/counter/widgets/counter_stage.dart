import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_layout.dart';
import '../../shared/widgets/grow_with_screen.dart';
import '../bloc/counter_bloc.dart';
import '../viewmodels/counter_view_model.dart';
import 'count_button.dart';
import 'goal_ring.dart';

/// The middle of the screen: the progress ring above the count button.
/// Grows on large screens, and scales down uniformly on small ones instead
/// of overflowing.
class CounterStage extends StatelessWidget {
  const CounterStage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.stageVerticalPadding * AppLayout.spacingOf(context),
        horizontal: AppDimensions.stageHorizontalPadding,
      ),
      child: const Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: GrowWithScreen(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.countButtonTopGap,
              children: [CounterProgress(), CounterTapButton()],
            ),
          ),
        ),
      ),
    );
  }
}

/// The goal ring, showing the current count and progress.
class CounterProgress extends StatelessWidget {
  const CounterProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CounterBloc, CounterState, CounterViewModel>(
      selector: CounterViewModel.fromState,
      builder:
          (context, vm) => GoalRing(
            value: vm.displayValue,
            label: vm.ringLabel,
            progress: vm.progress,
            reached: vm.goalReached,
            semanticLabel: vm.countLabel,
          ),
    );
  }
}

/// The fingerprint button; the only thing on screen that counts.
class CounterTapButton extends StatelessWidget {
  const CounterTapButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CounterBloc, CounterState, int>(
      selector: (state) => state.count,
      builder:
          (context, count) => CountButton(
            semanticLabel: 'Tap to count. Current count: $count.',
            onPressed: () => context.read<CounterBloc>().add(const CounterIncremented()),
          ),
    );
  }
}
