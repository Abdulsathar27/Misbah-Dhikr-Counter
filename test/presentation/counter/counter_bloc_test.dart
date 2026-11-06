import 'package:bloc_test/bloc_test.dart';
import 'package:counter/core/errors/failures.dart';
import 'package:counter/domain/entities/counter_entity.dart';
import 'package:counter/presentation/counter/bloc/counter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeCounterRepository repository;
  late FakeHapticsService haptics;

  CounterBloc build({int? historyLimit}) =>
      historyLimit == null
          ? CounterBloc(repository: repository, haptics: haptics)
          : CounterBloc(repository: repository, haptics: haptics, undoHistoryLimit: historyLimit);

  CounterState ready(CounterEntity counter) =>
      CounterState(status: CounterStatus.ready, counter: counter);

  setUp(() {
    repository = FakeCounterRepository();
    haptics = FakeHapticsService();
  });

  group('CounterInitialized', () {
    blocTest<CounterBloc, CounterState>(
      'loads the saved count',
      setUp: () => repository.stored = const CounterEntity(count: 41, undoHistory: [40]),
      build: build,
      act: (bloc) => bloc.add(const CounterInitialized()),
      expect:
          () => [
            ready(const CounterEntity(count: 41, undoHistory: [40])),
          ],
    );

    blocTest<CounterBloc, CounterState>(
      'falls back to zero and reports a failure when loading fails',
      setUp: () => repository.failLoad = true,
      build: build,
      act: (bloc) => bloc.add(const CounterInitialized()),
      expect:
          () => [
            isA<CounterState>()
                .having((s) => s.isReady, 'isReady', isTrue)
                .having((s) => s.count, 'count', 0)
                .having((s) => s.failure, 'failure', isA<PersistenceFailure>()),
          ],
    );
  });

  group('CounterIncremented', () {
    blocTest<CounterBloc, CounterState>(
      'adds exactly one, persists it and vibrates',
      build: build,
      seed: () => ready(const CounterEntity(count: 9)),
      act: (bloc) => bloc.add(const CounterIncremented()),
      expect:
          () => [
            ready(const CounterEntity(count: 10, undoHistory: [9])),
          ],
      verify: (_) {
        expect(repository.stored.count, 10);
        expect(haptics.ticks, 1);
      },
    );

    blocTest<CounterBloc, CounterState>(
      'gives the goal pulse instead of a tick on the count that reaches the goal',
      build: build,
      seed: () => ready(const CounterEntity(count: 10, goal: 12)),
      act:
          (bloc) =>
              bloc
                ..add(const CounterIncremented())
                ..add(const CounterIncremented()),
      verify: (_) {
        expect(haptics.ticks, 1);
        expect(haptics.goalsReached, 1);
      },
    );

    blocTest<CounterBloc, CounterState>(
      'gives no goal pulse when vibration is off',
      build: build,
      seed: () => ready(const CounterEntity(count: 11, goal: 12, vibrationEnabled: false)),
      act: (bloc) => bloc.add(const CounterIncremented()),
      verify: (_) => expect(haptics.goalsReached, 0),
    );

    blocTest<CounterBloc, CounterState>(
      'stops at the goal without saving or vibrating',
      build: build,
      seed: () => ready(const CounterEntity(count: 12, goal: 12)),
      act: (bloc) => bloc.add(const CounterIncremented()),
      expect: () => <CounterState>[],
      verify: (_) {
        expect(repository.saveCountCalls, 0);
        expect(haptics.ticks, 0);
      },
    );

    blocTest<CounterBloc, CounterState>(
      'does not vibrate when vibration is off',
      build: build,
      seed: () => ready(const CounterEntity(count: 0, vibrationEnabled: false)),
      act: (bloc) => bloc.add(const CounterIncremented()),
      verify: (_) => expect(haptics.ticks, 0),
    );

    blocTest<CounterBloc, CounterState>(
      'applies every one of many rapid taps in order',
      build: build,
      seed: () => ready(const CounterEntity(count: 0)),
      act: (bloc) {
        for (var i = 0; i < 250; i++) {
          bloc.add(const CounterIncremented());
        }
      },
      verify: (bloc) {
        expect(bloc.state.count, 250);
        expect(repository.stored.count, 250);
        expect(repository.saveCountCalls, 250);
      },
    );

    blocTest<CounterBloc, CounterState>(
      'caps the undo history',
      build: () => build(historyLimit: 3),
      seed: () => ready(const CounterEntity(count: 0)),
      act: (bloc) {
        for (var i = 0; i < 5; i++) {
          bloc.add(const CounterIncremented());
        }
      },
      verify: (bloc) => expect(bloc.state.counter.undoHistory, [2, 3, 4]),
    );

    blocTest<CounterBloc, CounterState>(
      'keeps the new value on screen and reports a failure when saving fails',
      setUp: () => repository.failSave = true,
      build: build,
      seed: () => ready(const CounterEntity(count: 1)),
      act: (bloc) => bloc.add(const CounterIncremented()),
      expect:
          () => [
            ready(const CounterEntity(count: 2, undoHistory: [1])),
            const CounterState(
              status: CounterStatus.ready,
              counter: CounterEntity(count: 2, undoHistory: [1]),
              failure: PersistenceFailure(),
            ),
          ],
    );
  });

  group('CounterUndoRequested', () {
    blocTest<CounterBloc, CounterState>(
      'restores the previous count',
      build: build,
      seed: () => ready(const CounterEntity(count: 5, undoHistory: [3, 4])),
      act: (bloc) => bloc.add(const CounterUndoRequested()),
      expect:
          () => [
            ready(const CounterEntity(count: 4, undoHistory: [3])),
          ],
      verify: (_) => expect(repository.stored.count, 4),
    );

    blocTest<CounterBloc, CounterState>(
      'never goes below zero',
      build: build,
      seed: () => ready(const CounterEntity(count: 0)),
      act:
          (bloc) =>
              bloc
                ..add(const CounterUndoRequested())
                ..add(const CounterUndoRequested()),
      expect: () => <CounterState>[],
    );

    blocTest<CounterBloc, CounterState>(
      'stops at zero after undoing every increment',
      build: build,
      seed: () => ready(const CounterEntity(count: 0)),
      act:
          (bloc) =>
              bloc
                ..add(const CounterIncremented())
                ..add(const CounterIncremented())
                ..add(const CounterUndoRequested())
                ..add(const CounterUndoRequested())
                ..add(const CounterUndoRequested()),
      verify: (bloc) {
        expect(bloc.state.count, 0);
        expect(bloc.state.canUndo, isFalse);
      },
    );
  });

  group('CounterResetRequested', () {
    blocTest<CounterBloc, CounterState>(
      'returns to zero and persists it',
      build: build,
      seed: () => ready(const CounterEntity(count: 37, undoHistory: [36])),
      act: (bloc) => bloc.add(const CounterResetRequested()),
      expect:
          () => [
            ready(const CounterEntity(count: 0, undoHistory: [36, 37])),
          ],
      verify: (_) {
        expect(repository.stored.count, 0);
        expect(haptics.confirms, 1);
      },
    );

    blocTest<CounterBloc, CounterState>(
      'can be undone',
      build: build,
      seed: () => ready(const CounterEntity(count: 37)),
      act:
          (bloc) =>
              bloc
                ..add(const CounterResetRequested())
                ..add(const CounterUndoRequested()),
      verify: (bloc) => expect(bloc.state.count, 37),
    );

    blocTest<CounterBloc, CounterState>(
      'does nothing when already at zero',
      build: build,
      seed: () => ready(const CounterEntity(count: 0)),
      act: (bloc) => bloc.add(const CounterResetRequested()),
      expect: () => <CounterState>[],
    );
  });

  group('CounterVibrationToggled', () {
    blocTest<CounterBloc, CounterState>(
      'switches vibration off and back on, persisting each change',
      build: build,
      seed: () => ready(const CounterEntity(count: 3)),
      act:
          (bloc) =>
              bloc
                ..add(const CounterVibrationToggled())
                ..add(const CounterVibrationToggled()),
      expect:
          () => [
            ready(const CounterEntity(count: 3, vibrationEnabled: false)),
            ready(const CounterEntity(count: 3)),
          ],
      verify: (_) {
        expect(repository.stored.vibrationEnabled, isTrue);
        expect(haptics.confirms, 1, reason: 'only switching on gives a pulse');
      },
    );
  });

  group('CounterGoalChanged', () {
    blocTest<CounterBloc, CounterState>(
      'sets and persists the goal',
      build: build,
      seed: () => ready(const CounterEntity(count: 3)),
      act: (bloc) => bloc.add(const CounterGoalChanged(33)),
      expect: () => [ready(const CounterEntity(count: 3, goal: 33))],
      verify: (_) => expect(repository.stored.goal, 33),
    );

    blocTest<CounterBloc, CounterState>(
      'gives the goal pulse when a goal at or below the count is set',
      build: build,
      seed: () => ready(const CounterEntity(count: 5)),
      act: (bloc) => bloc.add(const CounterGoalChanged(5)),
      verify: (_) => expect(haptics.goalsReached, 1),
    );

    blocTest<CounterBloc, CounterState>(
      'clamps an out-of-range goal',
      build: build,
      seed: () => ready(const CounterEntity(count: 3)),
      act: (bloc) => bloc.add(const CounterGoalChanged(0)),
      expect: () => [ready(const CounterEntity(count: 3, goal: 1))],
    );

    blocTest<CounterBloc, CounterState>(
      'ignores a goal equal to the current one',
      build: build,
      seed: () => ready(const CounterEntity(count: 3, goal: 10)),
      act: (bloc) => bloc.add(const CounterGoalChanged(10)),
      expect: () => <CounterState>[],
    );

    blocTest<CounterBloc, CounterState>(
      'removes the goal when given null',
      build: build,
      seed: () => ready(const CounterEntity(count: 3, goal: 10)),
      act: (bloc) => bloc.add(const CounterGoalChanged(null)),
      expect: () => [ready(const CounterEntity(count: 3))],
      verify: (_) => expect(repository.stored.goal, isNull),
    );

    test('without a goal the ring is full and never reached', () {
      final state = ready(const CounterEntity(count: 50));
      expect(state.goal, isNull);
      expect(state.progress, 1);
      expect(state.goalReached, isFalse);
    });

    test('progress fills towards the goal and stays full past it', () {
      expect(ready(const CounterEntity(count: 0, goal: 4)).progress, 0);
      expect(ready(const CounterEntity(count: 1, goal: 4)).progress, 0.25);
      expect(ready(const CounterEntity(count: 4, goal: 4)).goalReached, isTrue);
      expect(ready(const CounterEntity(count: 9, goal: 4)).progress, 1);
    });
  });
}
