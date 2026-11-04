import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../counter/views/counter_page.dart';
import '../widgets/splash_mark.dart';
import '../widgets/splash_text.dart';

/// The launch screen: the ring draws itself around the fingerprint, MISBAH
/// and the tagline rise in, then the counter fades in. Tap to skip.
///
/// With reduced motion everything is shown at once and only the hold remains.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _mark;
  late Animation<double> _title;
  late Animation<double> _tagline;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    // Runs even under reduced motion: it also times the hold before leaving.
    _controller =
        AnimationController(vsync: this, duration: AppMotion.splash)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _openCounter();
          })
          ..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    Animation<double> phase(double begin, double end) =>
        still
            ? kAlwaysCompleteAnimation
            : CurvedAnimation(
              parent: _controller,
              curve: Interval(begin, end, curve: Curves.easeOutCubic),
            );
    _mark = phase(0, 0.45);
    _title = phase(0.25, 0.6);
    _tagline = phase(0.45, 0.75);
  }

  void _openCounter() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: AppMotion.of(context, AppMotion.splashExit),
        pageBuilder: (_, _, _) => const CounterPage(),
        transitionsBuilder:
            (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openCounter,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.stageHorizontalPadding),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SplashMark(progress: _mark),
                    const SizedBox(height: AppDimensions.splashTitleGap),
                    SplashWordmark(animation: _title),
                    const SizedBox(height: AppDimensions.splashTaglineGap),
                    SplashTagline(animation: _tagline),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
