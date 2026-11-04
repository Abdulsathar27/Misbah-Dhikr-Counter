import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../presentation/counter/bloc/counter_bloc.dart';
import '../presentation/counter/views/counter_page.dart';
import '../presentation/splash/views/splash_page.dart';
import 'theme/app_theme.dart';

class MisbahApp extends StatelessWidget {
  const MisbahApp({super.key, required this.counterBloc, this.showSplash = true});

  /// Created and initialised before the first frame so the saved count is
  /// ready the moment the counter appears, never a placeholder.
  final CounterBloc counterBloc;

  /// Opens on the splash; false goes straight to the counter (used in tests).
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: counterBloc,
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: showSplash ? const SplashPage() : const CounterPage(),
      ),
    );
  }
}
