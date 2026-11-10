import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/theme/app_colors.dart';
import 'injection/dependency_injection.dart';
import 'presentation/counter/bloc/counter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.canvas,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await configureDependencies();

  // Load the saved settings before the first frame, so the counter shows the
  // goal and vibration setting straight away.
  final counterBloc = sl<CounterBloc>()..add(const CounterInitialized());
  await counterBloc.stream.firstWhere((state) => state.isReady);

  runApp(MisbahApp(counterBloc: counterBloc));
}
