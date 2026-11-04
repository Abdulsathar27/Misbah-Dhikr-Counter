import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

/// Fades [child] in while it rises a little, driven by [animation].
class RiseIn extends StatelessWidget {
  const RiseIn({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

/// The MISBAH wordmark. Its letters start wide apart and draw together as
/// [animation] runs.
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key, required this.animation});

  final Animation<double> animation;

  static const double _startSpacingEm = 0.9;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: AppConstants.brandName,
      excludeSemantics: true,
      child: RiseIn(
        animation: animation,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final em =
                _startSpacingEm +
                (AppTypography.brandLetterSpacingEm - _startSpacingEm) * animation.value;
            final spacing = AppTypography.splashTitleFontSize * em;
            return Padding(
              // Letter spacing trails the last glyph; pad the start to match
              // so the word stays optically centred.
              padding: EdgeInsetsDirectional.only(start: spacing),
              child: Text(
                AppConstants.brandName.toUpperCase(),
                maxLines: 1,
                style: AppTypography.splashTitle.copyWith(letterSpacing: spacing),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// "Count Your Dhikr. Connect Your Heart" under the wordmark.
class SplashTagline extends StatelessWidget {
  const SplashTagline({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RiseIn(
      animation: animation,
      child: const Text(
        AppConstants.tagline,
        textAlign: TextAlign.center,
        style: AppTypography.tagline,
      ),
    );
  }
}
