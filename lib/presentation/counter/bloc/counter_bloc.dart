import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/services/haptics_service.dart';
import '../../../domain/entities/counter_entity.dart';
import '../../../domain/repositories/counter_repository.dart';

part 'counter_event.dart';
part 'counter_state.dart';

/// Single source of truth for the counter.
///
/// All events go through one [sequential] queue: every tap is applied exactly
/// once and in order, none are dropped, and a save always finishes before the
/// next change is computed, so rapid tapping cannot lose updates.
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc({
    required this._repository,
    required this._haptics,
    this._undoHistoryLimit = AppConstants.undoHistoryLimit,
  }) : super(const CounterState()) {
    on<CounterEvent>(
      (event, emit) => switch (event) {
        CounterInitialized() => _onInitialized(emit),
        CounterIncremented() => _onIncremented(emit),
        CounterUndoRequested() => _onUndoRequested(emit),
        CounterResetRequested() => _onResetRequested(emit),
        CounterVibrationToggled() => _onVibrationToggled(emit),
        CounterGoalChanged(:final goal) => _onGoalChanged(emit, goal),
      },
      transformer: sequential(),
    );
  }

  final CounterRepository _repository;
  final HapticsService _haptics;
  final int _undoHistoryLimit;

  Future<void> _onInitialized(Emitter<CounterState> emit) async {
    try {
      final saved = await _repository.load();
      emit(CounterState(status: CounterStatus.ready, counter: saved));
    } on Object {
      emit(
        const CounterState(
          status: CounterStatus.ready,
          failure: PersistenceFailure('Your saved settings could not be loaded.'),
        ),
      );
    }
  }

  Future<void> _onIncremented(Emitter<CounterState> emit) async {
    // Counting stops at the goal until the user decides what comes next.
    if (state.goalReached) return;
    final current = state.counter;
    final next = current.count + 1;
    _feedback(next == current.goal ? _haptics.goalReached : _haptics.tick);
    _setCount(emit, current.copyWith(count: next, undoHistory: _pushHistory(current)));
  }

  Future<void> _onUndoRequested(Emitter<CounterState> emit) async {
    final current = state.counter;
    if (current.undoHistory.isEmpty) return;
    _feedback(_haptics.tick);
    final history = current.undoHistory;
    _setCount(
      emit,
      current.copyWith(
        count: history.last,
        undoHistory: List.unmodifiable(history.sublist(0, history.length - 1)),
      ),
    );
  }

  Future<void> _onResetRequested(Emitter<CounterState> emit) async {
    final current = state.counter;
    if (current.count == 0) return;
    _feedback(_haptics.confirm);
    // The value before the reset is kept, so an accidental reset can be undone.
    _setCount(emit, current.copyWith(count: 0, undoHistory: _pushHistory(current)));
  }

  Future<void> _onVibrationToggled(Emitter<CounterState> emit) async {
    final enabled = !state.vibrationEnabled;
    emit(state.copyWith(counter: state.counter.copyWith(vibrationEnabled: enabled)));
    if (enabled) unawaited(_haptics.confirm());
    try {
      await _repository.saveVibrationEnabled(enabled: enabled);
      if (state.failure != null) emit(state.copyWith(failure: () => null));
    } on Object {
      emit(state.copyWith(failure: () => const PersistenceFailure()));
    }
  }

  Future<void> _onGoalChanged(Emitter<CounterState> emit, int? requested) async {
    final goal = requested?.clamp(AppConstants.minGoal, AppConstants.maxGoal);
    if (goal == state.goal) return;
    emit(state.copyWith(counter: state.counter.copyWith(goal: () => goal)));
    if (state.goalReached) _feedback(_haptics.goalReached);
    try {
      await _repository.saveGoal(goal);
      if (state.failure != null) emit(state.copyWith(failure: () => null));
    } on Object {
      emit(state.copyWith(failure: () => const PersistenceFailure()));
    }
  }

  void _setCount(Emitter<CounterState> emit, CounterEntity next) {
    emit(state.copyWith(counter: next));
  }

  List<int> _pushHistory(CounterEntity current) {
    final history = [...current.undoHistory, current.count];
    final overflow = history.length - _undoHistoryLimit;
    return List.unmodifiable(overflow > 0 ? history.sublist(overflow) : history);
  }

  void _feedback(Future<void> Function() pattern) {
    if (state.vibrationEnabled) unawaited(pattern());
  }
}
