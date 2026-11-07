import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How the layout adapts to the screen. The design is drawn for a 390×844
/// phone: on that size and smaller everything is drawn as designed (and
/// shrinks to fit where space runs out); larger screens draw it bigger.
abstract final class AppLayout {
  static const Size designSize = Size(390, 844);

  /// The most the main elements grow, reached on tablets.
  static const double maxGrowth = 1.5;

  /// The least vertical spacing shrinks to on short screens.
  static const double minSpacing = 0.5;

  /// How much larger than designed to draw the main elements: 1 up to the
  /// design size, growing with the screen to [maxGrowth]. Never below 1;
  /// tight spaces are handled by scaling down to fit instead.
  static double growthOf(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final ratio = math.min(size.width / designSize.width, size.height / designSize.height);
    return ratio.clamp(1.0, maxGrowth);
  }

  /// How much of the designed vertical spacing to use: all of it on screens
  /// as tall as the design or taller, less on shorter ones, down to
  /// [minSpacing], so the main elements keep as much room as possible.
  static double spacingOf(BuildContext context) =>
      (MediaQuery.sizeOf(context).height / designSize.height).clamp(minSpacing, 1.0);
}
