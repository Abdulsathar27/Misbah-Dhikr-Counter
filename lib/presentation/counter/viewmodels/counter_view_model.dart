import 'package:equatable/equatable.dart';

import '../bloc/counter_bloc.dart';

/// What the goal ring shows, formatted from [CounterState]. Equatable so the
/// ring rebuilds only when one of these values actually changes.
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

  final int count;

  /// Null when the user has not set a goal.
  final int? goal;
  final double progress;
  final bool goalReached;

  String get displayValue => '$count';

  /// Under the count: how many are left, that the goal is reached, or that
  /// there is no goal yet.
  String get ringLabel => switch (goal) {
    null => 'no goal set',
    _ when goalReached => 'goal reached',
    final goal => '${goal - count} to go',
  };

  /// Read out for the ring.
  String get countLabel => switch (goal) {
    null => 'Current count: $count.',
    _ when goalReached => 'Current count: $count. Goal of $goal reached.',
    final goal => 'Current count: $count of $goal.',
  };

  @override
  List<Object?> get props => [count, goal, progress, goalReached];
}
