import 'package:flutter/widgets.dart';

import '../../../app/theme/app_dimensions.dart';

/// Fades [child] in while it rises into place at launch. [delay] is the share
/// of the intro to wait first (0–1), so sections arrive one after another.
class EntranceAnimation extends StatelessWidget {
  const EntranceAnimation({super.key, this.delay = 0, required this.child});

  final double delay;
  final Widget child;

  static const double _rise = 24;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, AppMotion.intro),
      curve: Interval(delay, 1, curve: AppMotion.introCurve),
      child: child,
      builder:
          (context, t, child) => Opacity(
            opacity: t,
            // Stays visible to assistive tech while it fades in.
            alwaysIncludeSemantics: true,
            child: Transform.translate(offset: Offset(0, _rise * (1 - t)), child: child),
          ),
    );
  }
}
