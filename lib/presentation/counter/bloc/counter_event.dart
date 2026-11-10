part of 'counter_bloc.dart';

sealed class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the saved settings, with the count at 0. Dispatched once when the
/// BLoC is created.
final class CounterInitialized extends CounterEvent {
  const CounterInitialized();
}

/// The user tapped the counter.
final class CounterIncremented extends CounterEvent {
  const CounterIncremented();
}

final class CounterResetRequested extends CounterEvent {
  const CounterResetRequested();
}

final class CounterVibrationToggled extends CounterEvent {
  const CounterVibrationToggled();
}

/// Sets the goal the progress ring fills towards, or removes it when [goal]
/// is null. Out-of-range values are clamped to the allowed range.
final class CounterGoalChanged extends CounterEvent {
  const CounterGoalChanged(this.goal);

  final int? goal;

  @override
  List<Object?> get props => [goal];
}
