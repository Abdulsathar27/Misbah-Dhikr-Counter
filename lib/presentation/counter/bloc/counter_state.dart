part of 'counter_bloc.dart';

enum CounterStatus { initial, ready }

final class CounterState extends Equatable {
  const CounterState({
    this.status = CounterStatus.initial,
    this.counter = CounterEntity.initial,
    this.failure,
  });

  final CounterStatus status;
  final CounterEntity counter;

  /// The most recent persistence error, cleared by the next successful save.
  final Failure? failure;

  int get count => counter.count;
  bool get vibrationEnabled => counter.vibrationEnabled;
  bool get isReady => status == CounterStatus.ready;

  /// Null until the user sets a goal.
  int? get goal => counter.goal;
  bool get hasGoal => goal != null;
  bool get goalReached => hasGoal && count >= goal!;

  /// How full the ring is, from 0 to 1. Always full without a goal, as there
  /// is nothing to fill towards; otherwise full from the goal onwards.
  double get progress => hasGoal ? (count / goal!).clamp(0.0, 1.0) : 1;

  CounterState copyWith({
    CounterStatus? status,
    CounterEntity? counter,
    Failure? Function()? failure,
  }) {
    return CounterState(
      status: status ?? this.status,
      counter: counter ?? this.counter,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [status, counter, failure];
}
