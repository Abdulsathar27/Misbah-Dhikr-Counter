import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../shared/widgets/rise_in.dart';

/// How far splash text rises as it fades in: further than [RiseIn]'s default,
/// for a slower arrival.
const double _rise = 0.4;

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
        rise: _rise,
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
      rise: _rise,
      child: const Text(
        AppConstants.tagline,
        textAlign: TextAlign.center,
        style: AppTypography.tagline,
      ),
    );
  }
}
