import 'package:equatable/equatable.dart';

import '../bloc/counter_bloc.dart';

/// UI-ready projections of [CounterState]. They only format; the BLoC stays
/// the single source of truth. Each is equatable so a `BlocSelector` rebuilds
/// its part of the screen only when that part actually changes.
class CounterViewModel extends Equatable {
  const CounterViewModel({
    required this.count,
    required this.goal,
    required this.progress,
    required this.goalReached,
  });

  factory CounterViewModel.fromState(CounterState state) => CounterViewModel(
    count: state.count,
    goal: state.goal,
    progress: state.progress,
    goalReached: state.goalReached,
  );

  static const String goalReachedLabel = 'goal reached';

  final int count;
  final int goal;
  final double progress;
  final bool goalReached;

  String get displayValue => '$count';

  /// Under the count: how many are left, or that the goal is reached.
  String get ringLabel => goalReached ? goalReachedLabel : '${goal - count} to go';

  /// Read out for the ring.
  String get countLabel =>
      goalReached
          ? 'Current count: $count. Goal of $goal reached.'
          : 'Current count: $count of $goal.';

  /// Read out for the fingerprint button.
  String get semanticLabel => 'Tap to count. Current count: $count.';

  @override
  List<Object?> get props => [count, goal, progress, goalReached];
}

class CounterControlsViewModel extends Equatable {
  const CounterControlsViewModel({
    required this.canUndo,
    required this.canReset,
    required this.vibrationEnabled,
    required this.goal,
  });

  factory CounterControlsViewModel.fromState(CounterState state) => CounterControlsViewModel(
    canUndo: state.canUndo,
    canReset: state.count > 0,
    vibrationEnabled: state.vibrationEnabled,
    goal: state.goal,
  );

  static const String undoLabel = 'Undo last count';
  static const String resetLabel = 'Reset count';

  final bool canUndo;

  /// Reset does nothing at zero, so the button is disabled there.
  final bool canReset;
  final bool vibrationEnabled;
  final int goal;

  String get vibrationLabel => 'Vibration: ${vibrationEnabled ? 'on' : 'off'}';

  String get goalLabel => 'Set goal. Current goal: $goal';

  @override
  List<Object?> get props => [canUndo, canReset, vibrationEnabled, goal];
}
