import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Typography tokens. Switzer is used throughout.
abstract final class AppTypography {
  static const String bodyFamily = 'Switzer';

  /// Wordmark: 15px, weight 300, uppercase, letter-spacing .46em.
  static const double brandFontSize = 15;
  static const double brandLetterSpacingEm = 0.46;
  static const TextStyle brand = TextStyle(
    fontFamily: bodyFamily,
    fontSize: brandFontSize,
    fontWeight: FontWeight.w300,
    letterSpacing: brandFontSize * brandLetterSpacingEm,
    height: 1.5,
    color: AppColors.foreground,
  );

  /// The splash wordmark: the brand style, larger.
  static const double splashTitleFontSize = 30;
  static const TextStyle splashTitle = TextStyle(
    fontFamily: bodyFamily,
    fontSize: splashTitleFontSize,
    fontWeight: FontWeight.w300,
    letterSpacing: splashTitleFontSize * brandLetterSpacingEm,
    height: 1.2,
    color: AppColors.foreground,
  );

  /// The splash tagline under the wordmark.
  static const TextStyle tagline = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.5,
    color: AppColors.secondary,
  );

  /// The count in the middle of the ring.
  static const TextStyle count = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 76,
    fontWeight: FontWeight.w400,
    height: 1,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.accent,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// "goal reached" / "3 to go" under the count.
  static const TextStyle ringLabel = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.secondary,
  );
}
