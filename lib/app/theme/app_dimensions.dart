import 'package:flutter/widgets.dart';

/// Layout, shape and motion tokens.
abstract final class AppDimensions {
  // Screen.
  static const double screenTopPadding = 48;

  // Stage.
  static const double stageVerticalPadding = 32;
  static const double stageHorizontalPadding = 24;
  static const double countButtonTopGap = 40;

  // Progress ring. The stroke is ~8% of the diameter, as in the design.
  static const double ringDiameter = 240;
  static const double ringStroke = 18;
  static const double ringLabelGap = 6;

  /// Horizontal room the number has inside the ring before it scales down.
  static const double ringContentWidth = 168;

  // Fingerprint count button.
  static const double countButtonSize = 84;
  static const double countButtonIconSize = 40;
  static const double countButtonIconStroke = 1.5;

  // Controls.
  static const double controlSize = 56;
  static const double controlIconSize = 24;
  static const double controlIconStroke = 1.75;
  static const double controlGap = 24;
  static const double controlsTopPadding = 24;
  static const double controlsHorizontalPadding = 32;
  static const double controlsBottomPadding = 58;
  static const double controlsMinBottomPadding = 24;

  // Splash.
  // The mark keeps the logo's proportions: its ring is 35/778 of the width and
  // its disc 614/778.
  static const double splashMarkSize = 148;
  static const double splashMarkStroke = 6.7;
  static const double splashMarkDiscSize = 117;
  static const double splashTitleGap = 36;
  static const double splashTaglineGap = 12;

  // Focus ring.
  static const double focusRingWidth = 2;
  static const double controlFocusOffset = 3;
}

abstract final class AppMotion {
  /// [duration], or zero when the platform asks for reduced motion.
  static Duration of(BuildContext context, Duration duration) =>
      (MediaQuery.maybeDisableAnimationsOf(context) ?? false) ? Duration.zero : duration;

  /// The whole splash: mark, wordmark and tagline arriving, then a short hold.
  static const Duration splash = Duration(milliseconds: 2400);

  /// The splash handing over to the counter screen.
  static const Duration splashExit = Duration(milliseconds: 400);

  /// Screen content sliding and fading in at launch.
  static const Duration intro = Duration(milliseconds: 700);
  static const Curve introCurve = Curves.easeOutCubic;

  /// The count, its label and control icons swapping to a new value.
  static const Duration swap = Duration(milliseconds: 250);

  /// The ring easing to its new fill after each count or goal change.
  static const Duration ring = Duration(milliseconds: 350);
  static const Curve ringCurve = Curves.easeOutCubic;

  /// Button press: transform .15s ease.
  static const Duration press = Duration(milliseconds: 150);
  static const Curve pressCurve = Curves.ease;

  /// Ripple that spreads from the touch point on the count button.
  static const Duration ripple = Duration(milliseconds: 500);
  static const Curve rippleCurve = Curves.easeOutCubic;
}
