import 'package:counter/app/app.dart';
import 'package:counter/domain/entities/counter_entity.dart';
import 'package:counter/presentation/counter/bloc/counter_bloc.dart';
import 'package:counter/presentation/counter/widgets/count_button.dart';
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
    await tester.pumpWidget(MisbahApp(counterBloc: bloc));
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

  testWidgets('tapping the button counts and fills the ring', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 0, goal: 4));

    await tester.tap(tapArea);
    await tester.pumpAndSettle();

    expect(ringShows('1'), findsOneWidget);
    expect(ringShows('3 to go'), findsOneWidget);
    expect(ringProgress(tester), closeTo(0.25, 1e-9));
    expect(repository.stored.count, 1);
  });

  testWidgets('shows "goal reached" at the goal and stays full past it', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 11, goal: 12));

    await tester.tap(tapArea);
    await tester.pumpAndSettle();
    expect(ringShows('12'), findsOneWidget);
    expect(ringShows('goal reached'), findsOneWidget);
    expect(ringProgress(tester), 1);

    await tester.tap(tapArea);
    await tester.pumpAndSettle();
    expect(ringShows('13'), findsOneWidget);
    expect(ringShows('goal reached'), findsOneWidget);
    expect(ringProgress(tester), 1);
  });

  testWidgets('only the fingerprint button counts, not the ring or the screen', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 5));

    await tester.tap(ring, warnIfMissed: false);
    await tester.tapAt(tester.getTopLeft(ring) - const Offset(4, 4));
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(ringShows('5'), findsOneWidget);
    expect(repository.stored.count, 5);

    await tester.tap(tapArea);
    await tester.pumpAndSettle();
    expect(ringShows('6'), findsOneWidget);
    expect(repository.stored.count, 6);
  });

  testWidgets('rapid taps are all counted', (tester) async {
    await pumpApp(tester);

    for (var i = 0; i < 12; i++) {
      await tester.tap(tapArea);
      await tester.pump(const Duration(milliseconds: 30));
    }
    await tester.pumpAndSettle();

    expect(ringShows('12'), findsOneWidget);
    expect(repository.stored.count, 12);
  });

  testWidgets('undo and reset controls update the counter', (tester) async {
    await pumpApp(tester, saved: const CounterEntity(count: 7));

    await tester.tap(tapArea);
    await tester.pumpAndSettle();
    expect(ringShows('8'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Undo last count'));
    await tester.pumpAndSettle();
    expect(ringShows('7'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Reset count'));
    await tester.pumpAndSettle();
    expect(ringShows('0'), findsOneWidget);
    expect(ringProgress(tester), 0);
    expect(repository.stored.count, 0);
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

  testWidgets('tells the user when the saved count could not be loaded', (tester) async {
    repository.failLoad = true;
    await pumpApp(tester);
    await tester.pump();

    expect(find.text('Your saved count could not be loaded.'), findsOneWidget);
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
    final controlBottom = tester.getBottomLeft(find.bySemanticsLabel('Undo last count')).dy;
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
    await pumpApp(tester, saved: const CounterEntity(count: 3, undoHistory: [2]));

    expect(
      tester.getSemantics(tapArea),
      isSemantics(label: 'Tap to count. Current count: 3.', isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(ring),
      isSemantics(label: 'Current count: 3 of 10.', isButton: false, isLiveRegion: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Undo last count')),
      isSemantics(isButton: true, isEnabled: true, hasTapAction: true),
    );
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
    expect(tester.hasRunningAnimations, isFalse);
  });
}
