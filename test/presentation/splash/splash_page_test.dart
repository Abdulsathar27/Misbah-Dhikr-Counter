import 'package:counter/app/app.dart';
import 'package:counter/core/constants/app_constants.dart';
import 'package:counter/presentation/counter/bloc/counter_bloc.dart';
import 'package:counter/presentation/counter/views/counter_page.dart';
import 'package:counter/presentation/splash/views/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    final bloc = CounterBloc(repository: FakeCounterRepository(), haptics: FakeHapticsService())
      ..add(const CounterInitialized());
    await tester.runAsync(() => bloc.stream.firstWhere((s) => s.isReady));
    addTearDown(bloc.close);
    await tester.pumpWidget(MisbahApp(counterBloc: bloc));
  }

  testWidgets('shows the name and tagline, then opens the counter', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 1500));

    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.text('MISBAH'), findsOneWidget);
    expect(find.text(AppConstants.tagline), findsOneWidget);
    expect(find.byType(CounterPage), findsNothing);

    await tester.pumpAndSettle();
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(CounterPage), findsOneWidget);
  });

  testWidgets('a tap skips straight to the counter', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byType(SplashPage));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(CounterPage), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('with reduced motion shows everything at once and still leaves', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    await tester.pump();

    final tagline = tester.widget<FadeTransition>(
      find
          .ancestor(of: find.text(AppConstants.tagline), matching: find.byType(FadeTransition))
          .first,
    );
    expect(tagline.opacity.value, 1);

    await tester.pumpAndSettle();
    expect(find.byType(CounterPage), findsOneWidget);
  });
}
