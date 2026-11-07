import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

/// The counter: the current value, the vibration preference and the goal the
/// progress ring fills towards. There is no goal until the user sets one. Only the preference and
/// the goal are saved; the count starts at 0 on every launch.
class CounterEntity extends Equatable {
  const CounterEntity({
    required this.count,
    this.vibrationEnabled = true,
    this.goal,
  }) : assert(count >= 0, 'count must not be negative'),
       assert(goal == null || goal >= AppConstants.minGoal, 'goal must be positive');

  static const CounterEntity initial = CounterEntity(count: 0);

  final int count;
  final bool vibrationEnabled;

  /// Null when the user has not set a goal.
  final int? goal;

  /// [goal] is a function so that it can also clear the goal: pass
  /// `goal: () => null`.
  CounterEntity copyWith({
    int? count,
    bool? vibrationEnabled,
    int? Function()? goal,
  }) {
    return CounterEntity(
      count: count ?? this.count,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      goal: goal != null ? goal() : this.goal,
    );
  }

  @override
  List<Object?> get props => [count, vibrationEnabled, goal];
}
