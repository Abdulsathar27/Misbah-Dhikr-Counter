import 'package:counter/app/app.dart';
import 'package:counter/domain/entities/counter_entity.dart';
import 'package:counter/presentation/counter/bloc/counter_bloc.dart';
import 'package:counter/presentation/counter/widgets/count_button.dart';
import 'package:counter/presentation/counter/widgets/goal_reached_dialog.dart';
import 'package:counter/presentation/counter/widgets/goal_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeCounterRepository repository;

  setUp(() => repository = FakeCounterRepository());

  /// Mirrors main(): the bloc is initialised before the first frame.
  Future<CounterBloc> pumpApp(WidgetTester tester, {CounterEntity? saved}) async {
    if (saved != null) repository.stored = saved;
    final bloc = CounterBloc(repository: repository, haptics: FakeHapticsService())
      ..add(const CounterInitialized());
    await tester.runAsync(() => bloc.stream.firstWhere((s) => s.isReady));
    addTearDown(bloc.close);
    await tester.pumpWidget(MisbahApp(counterBloc: bloc, showSplash: false));
    return bloc;
  }

  final ring = find.byType(GoalRing);

  Finder ringShows(String text) => find.descendant(of: ring, matching: find.text(text));

  double ringProgress(WidgetTester tester) => tester.widget<GoalRing>(ring).progress;

  /// Only the fingerprint button counts; the ring is display-only.
  final tapArea = find.byType(CountButton);

  testWidgets('shows the saved count and goal progress on the first frame', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 4, goal: 10));

    expect(ringShows('4'), findsOneWidget);
    expect(ringShows('6 to go'), findsOneWidget);
    expect(ringProgress(tester), closeTo(0.4, 1e-9));
    expect(find.text('MISBAH'), findsOneWidget);
    expect(tapArea, findsOneWidget);
  });

  testWidgets('without a goal: a full ring, and the label goes once counting starts', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(ringShows('no goal set'), findsOneWidget);
    expect(ringProgress(tester), 1);

    for (var i = 0; i < 15; i++) {
      await tester.tap(tapArea);
    }
    await tester.pumpAndSettle();
    expect(ringShows('15'), findsOneWidget);
    expect(ringShows('no goal set'), findsNothing);
    expect(ringProgress(tester), 1);
  });

  testWidgets('a first goal can be set from an empty dialog', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 2));

    await tester.tap(find.bySemanticsLabel('Set goal. No goal set'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    expect(find.text('Remove'), findsNothing);

    await tester.enterText(find.byType(TextField), '33');
    await tester.pump(); // Save enables once the field holds a valid goal
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(ringShows('31 to go'), findsOneWidget);
    expect(repository.stored.goal, 33);
  });

  testWidgets('the goal can be removed again', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 2, goal: 10));

    await tester.tap(find.bySemanticsLabel('Set goal. Current goal: 10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(ringShows('2'), findsOneWidget);
    expect(ringShows('8 to go'), findsNothing);
    expect(ringProgress(tester), 1);
    expect(repository.stored.goal, isNull);
  });

  testWidgets('tapping the button counts and fills the ring', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 0, goal: 4));

    await tester.tap(tapArea);
    await tester.pumpAndSettle();

    expect(ringShows('1'), findsOneWidget);
    expect(ringShows('3 to go'), findsOneWidget);
    expect(ringProgress(tester), closeTo(0.25, 1e-9));
  });

  /// Counts from 11 up to a goal of 12, which opens the goal-reached dialog.
  Future<void> reachGoal(WidgetTester tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 11, goal: 12));
    await tester.tap(tapArea);
    await tester.pumpAndSettle();
  }

  testWidgets('reaching the goal fills the ring and asks what comes next', (tester) async {
    await reachGoal(tester);

    expect(ringShows('12'), findsOneWidget);
    expect(ringShows('goal reached'), findsOneWidget);
    expect(ringProgress(tester), 1);
    expect(find.byType(GoalReachedDialog), findsOneWidget);
    expect(find.text('Set new goal'), findsOneWidget);
    expect(find.text('Continue without goal'), findsOneWidget);
  });

  testWidgets('the goal-reached dialog must be answered', (tester) async {
    await reachGoal(tester);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(GoalReachedDialog), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(GoalReachedDialog), findsOneWidget);
  });

  testWidgets('continuing without a goal starts again from zero', (tester) async {
    await reachGoal(tester);

    await tester.tap(find.text('Continue without goal'));
    await tester.pumpAndSettle();
    expect(find.byType(GoalReachedDialog), findsNothing);
    expect(ringShows('0'), findsOneWidget);
    expect(ringShows('no goal set'), findsOneWidget);
    expect(ringProgress(tester), 1);
    expect(repository.stored.goal, isNull);

    await tester.tap(tapArea);
    await tester.pumpAndSettle();
    expect(ringShows('1'), findsOneWidget);
    expect(ringShows('no goal set'), findsNothing);
    expect(find.byType(GoalReachedDialog), findsNothing);
  });

  testWidgets('setting a new goal starts again from zero', (tester) async {
    await reachGoal(tester);

    await tester.tap(find.text('Set new goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '33');
    await tester.pump(); // Save enables once the field holds a valid goal
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(GoalReachedDialog), findsNothing);
    expect(ringShows('0'), findsOneWidget);
    expect(ringShows('33 to go'), findsOneWidget);
    expect(repository.stored.goal, 33);
  });

  testWidgets('cancelling the new goal asks again', (tester) async {
    await reachGoal(tester);

    await tester.tap(find.text('Set new goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(GoalReachedDialog), findsOneWidget);
    expect(ringShows('12'), findsOneWidget);
    expect(repository.stored.goal, 12);
  });

  testWidgets('the same goal can be set again and asks again next time', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 0, goal: 1));
    await tester.tap(tapArea);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Set new goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(ringShows('0'), findsOneWidget);
    expect(find.byType(GoalReachedDialog), findsNothing);

    await tester.tap(tapArea);
    await tester.pumpAndSettle();
    expect(find.byType(GoalReachedDialog), findsOneWidget);
  });

  testWidgets('only the fingerprint button counts, not the ring or the screen', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 5));

    await tester.tap(ring, warnIfMissed: false);
    await tester.tapAt(tester.getTopLeft(ring) - const Offset(4, 4));
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(ringShows('5'), findsOneWidget);

    await tester.tap(tapArea);
    await tester.pumpAndSettle();
    expect(ringShows('6'), findsOneWidget);
  });

  testWidgets('rapid taps are all counted', (tester) async {
    await pumpApp(tester);

    for (var i = 0; i < 12; i++) {
      await tester.tap(tapArea);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();

    expect(ringShows('12'), findsOneWidget);
  });

  testWidgets('the reset control sets the counter back to zero', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 7, goal: 10));

    await tester.tap(find.bySemanticsLabel('Reset count'));
    await tester.pumpAndSettle();
    expect(ringShows('0'), findsOneWidget);
    expect(ringProgress(tester), 0);
  });

  testWidgets('reset is disabled at zero', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, saved: const CounterEntity(count: 0));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Reset count')),
      isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
    );
    semantics.dispose();
  });

  testWidgets('tells the user when the saved settings could not be loaded', (tester) async {
    repository.failLoad = true;
    await pumpApp(tester);
    await tester.pump();

    expect(find.text('Your saved settings could not be loaded.'), findsOneWidget);
    expect(ringShows('0'), findsOneWidget);
  });

  testWidgets('does not double the bottom padding above the home indicator', (tester) async {
    tester.view
      ..padding = const FakeViewPadding(bottom: 34)
      ..viewPadding = const FakeViewPadding(bottom: 34)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.pumpAndSettle(); // let the launch animation finish

    final screenBottom = tester.getBottomLeft(find.byType(Scaffold)).dy;
    final controlBottom = tester.getBottomLeft(find.bySemanticsLabel('Reset count')).dy;
    // 58px from the screen edge, as in the reference, not 34 + 58.
    expect(screenBottom - controlBottom, closeTo(58, 1));
  });

  testWidgets('the goal button sets and saves a new goal', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 5, goal: 10));

    await tester.tap(find.bySemanticsLabel('Set goal. Current goal: 10'));
    await tester.pumpAndSettle();
    expect(find.text('Set goal'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(ringShows('goal reached'), findsOneWidget);
    expect(ringProgress(tester), 1);
    expect(repository.stored.goal, 5);
    expect(find.byType(GoalReachedDialog), findsOneWidget);
  });

  testWidgets('the goal dialog rejects zero and can be cancelled', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 2, goal: 10));

    await tester.tap(find.bySemanticsLabel('Set goal. Current goal: 10'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Save')).onPressed, isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(ringShows('8 to go'), findsOneWidget);
    expect(repository.stored.goal, 10);
  });

  testWidgets('the controls and the ring are accessible', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, saved: const CounterEntity(count: 3, goal: 10));

    expect(
      tester.getSemantics(tapArea),
      isSemantics(label: 'Tap to count. Current count: 3.', isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(ring),
      isSemantics(label: 'Current count: 3 of 10.', isButton: false, isLiveRegion: true),
    );
    expect(find.bySemanticsLabel('Undo last count'), findsNothing);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Reset count')),
      isSemantics(isButton: true, isEnabled: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Set goal. Current goal: 10')),
      isSemantics(isButton: true, isEnabled: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Vibration: on')),
      isSemantics(isButton: true, hasToggledState: true, isToggled: true, hasTapAction: true),
    );

    await tester.tap(find.bySemanticsLabel('Vibration: on'));
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Vibration: off')),
      isSemantics(isButton: true, hasToggledState: true, isToggled: false),
    );
    expect(repository.stored.vibrationEnabled, isFalse);

    semantics.dispose();
  });

  testWidgets('the counter can be activated from the keyboard', (tester) async {
    await pumpApp(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(ringShows('1'), findsOneWidget);
  });

  testWidgets('does not overflow on a small screen with large text', (tester) async {
    tester.view
      ..physicalSize = const Size(320, 480)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester, saved: const CounterEntity(count: 123456));

    expect(tester.takeException(), isNull);
    expect(ringShows('123456'), findsOneWidget);
  });

  testWidgets('skips the ring animation when the platform asks for reduced motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);

    await tester.tap(tapArea);
    await tester.pump();

    expect(ringShows('1'), findsOneWidget);
    expect(ringShows('no goal set'), findsNothing);
    expect(tester.takeException(), isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
