import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../bloc/counter_bloc.dart';
import 'counter_control_button.dart';
import 'goal_dialog.dart';
import 'line_icons.dart';

/// The row of round controls at the bottom of the screen. Each control
/// listens only to the part of the state it shows, so it rebuilds alone.
class CounterControls extends StatelessWidget {
  const CounterControls({super.key});

  @override
  Widget build(BuildContext context) {
    // The reference's 58px bottom padding includes the home-indicator area;
    // keep at least the minimum gap above the indicator.
    final bottomPadding = math.max(
      AppDimensions.controlsBottomPadding,
      MediaQuery.viewPaddingOf(context).bottom + AppDimensions.controlsMinBottomPadding,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Counter controls',
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.controlsHorizontalPadding,
          AppDimensions.controlsTopPadding,
          AppDimensions.controlsHorizontalPadding,
          bottomPadding,
        ),
        // Scales down on narrow screens instead of overflowing.
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: AppDimensions.controlGap,
            children: [UndoControl(), ResetControl(), VibrationControl(), GoalControl()],
          ),
        ),
      ),
    );
  }
}

/// Steps back to the previous count; disabled when there is nothing to undo.
class UndoControl extends StatelessWidget {
  const UndoControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CounterBloc, CounterState, bool>(
      selector: (state) => state.canUndo,
      builder:
          (context, canUndo) => CounterControlButton(
            glyph: LineIconGlyph.undo,
            semanticLabel: 'Undo last count',
            onPressed:
                canUndo
                    ? () => context.read<CounterBloc>().add(const CounterUndoRequested())
                    : null,
          ),
    );
  }
}

/// Sets the count back to zero; disabled when it is already zero.
class ResetControl extends StatelessWidget {
  const ResetControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CounterBloc, CounterState, bool>(
      selector: (state) => state.count > 0,
      builder:
          (context, canReset) => CounterControlButton(
            glyph: LineIconGlyph.reset,
            semanticLabel: 'Reset count',
            onPressed:
                canReset
                    ? () => context.read<CounterBloc>().add(const CounterResetRequested())
                    : null,
          ),
    );
  }
}

/// Switches vibration on and off; the icon swaps and dims when off.
class VibrationControl extends StatelessWidget {
  const VibrationControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CounterBloc, CounterState, bool>(
      selector: (state) => state.vibrationEnabled,
      builder:
          (context, enabled) => CounterControlButton(
            glyph: enabled ? LineIconGlyph.vibrate : LineIconGlyph.vibrateOff,
            semanticLabel: 'Vibration: ${enabled ? 'on' : 'off'}',
            toggled: enabled,
            iconColor: enabled ? AppColors.foreground : AppColors.secondary,
            onPressed: () => context.read<CounterBloc>().add(const CounterVibrationToggled()),
          ),
    );
  }
}

/// Opens the goal dialog and applies the goal entered there.
class GoalControl extends StatelessWidget {
  const GoalControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CounterBloc, CounterState, int>(
      selector: (state) => state.goal,
      builder:
          (context, goal) => CounterControlButton(
            glyph: LineIconGlyph.target,
            semanticLabel: 'Set goal. Current goal: $goal',
            onPressed: () async {
              final bloc = context.read<CounterBloc>();
              final newGoal = await showGoalDialog(context, current: goal);
              if (newGoal != null) bloc.add(CounterGoalChanged(newGoal));
            },
          ),
    );
  }
}
