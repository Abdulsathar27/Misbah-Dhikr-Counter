import 'package:counter/app/app.dart';
import 'package:counter/core/constants/app_constants.dart';
import 'package:counter/presentation/counter/bloc/counter_bloc.dart';
import 'package:counter/presentation/counter/widgets/about_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  testWidgets('the info button on the counter opens the About and privacy sheet', (tester) async {
    final bloc = CounterBloc(repository: FakeCounterRepository(), haptics: FakeHapticsService())
      ..add(const CounterInitialized());
    await tester.runAsync(() => bloc.stream.firstWhere((s) => s.isReady));
    addTearDown(bloc.close);
    await tester.pumpWidget(MisbahApp(counterBloc: bloc, showSplash: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('About and privacy'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutSheet), findsOneWidget);
    expect(find.text('Your privacy'), findsOneWidget);
    expect(find.text('Read the full privacy policy'), findsOneWidget);
    expect(find.text(AppConstants.privacyPolicyUrl), findsOneWidget);
  });

  Future<void> pumpSheet(WidgetTester tester, LinkOpener openLink) {
    return tester.pumpWidget(
      MaterialApp(home: Scaffold(body: AboutSheet(openLink: openLink))),
    );
  }

  testWidgets('the link opens the published privacy policy', (tester) async {
    final opened = <Uri>[];
    await pumpSheet(tester, (uri) async {
      opened.add(uri);
      return true;
    });

    await tester.tap(find.text('Read the full privacy policy'));
    await tester.pump();

    expect(opened, [Uri.parse(AppConstants.privacyPolicyUrl)]);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('says so when the link cannot be opened', (tester) async {
    await pumpSheet(tester, (_) async => false);

    await tester.tap(find.text('Read the full privacy policy'));
    await tester.pump();

    expect(find.textContaining('Could not open the privacy policy'), findsOneWidget);
  });

  test('the policy link points at the GitHub Pages copy in this repo', () {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, 'abdulsathar27.github.io');
    expect(uri.path, '/Misbah-Dhikr-Counter/privacy-policy.html');
  });
}
