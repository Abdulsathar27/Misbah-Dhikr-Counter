import 'package:flutter/painting.dart';

/// Color tokens, all drawn from the MISBAH logo palette.
abstract final class AppColors {
  // Brand palette.
  static const Color deepPine = Color(0xFF08392F);
  static const Color emerald = Color(0xFF0E5A4A);
  static const Color lampGold = Color(0xFFE9B54A);
  static const Color cream = Color(0xFFFFF4DC);

  /// Lamp gold darkened, for the raised edge under gold buttons.
  static const Color lampGoldShade = Color(0xFFB0812A);

  // Role tokens.
  static const Color canvas = deepPine;
  static const Color surface = emerald;
  static const Color foreground = cream;

  /// Cream at 72% over deep pine, for quieter text such as "5 to go".
  static const Color secondary = Color(0xFFBAC0AC);

  /// Cream at 20%: a hairline around the buttons.
  static const Color divider = Color(0x33FFF4DC);
  static const Color accent = lampGold;
  static const Color onAccent = deepPine;
  static const Color error = Color(0xFFEF5350);

  // Progress ring.
  static const Color ringTrack = emerald;
  static const Color ringProgress = lampGold;

  // Buttons: shadows sit on a dark canvas, so they are pure black.
  static const Color controlShadow = Color(0x66000000); // .40
  static const Color controlShadowPressed = Color(0x80000000); // .50

  // Count button ripple, cream at .14 at its start.
  static const Color ripple = Color(0x24FFF4DC);
}
