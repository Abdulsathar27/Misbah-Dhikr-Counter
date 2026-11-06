import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import 'disc_button.dart';
import 'line_icons.dart';

/// One of the round bottom controls. A changed icon (such as vibration
/// switching off) spins and fades in.
class CounterControlButton extends StatelessWidget {
  const CounterControlButton({
    super.key,
    required this.glyph,
    required this.semanticLabel,
    required this.onPressed,
    this.toggled,
    this.iconColor = AppColors.accent,
  });

  final LineIconGlyph glyph;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final bool? toggled;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DiscButton(
      size: AppDimensions.controlSize,
      semanticLabel: semanticLabel,
      onPressed: onPressed,
      toggled: toggled,
      child: Center(
        child: AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.swap),
          transitionBuilder:
              (child, animation) => FadeTransition(
                opacity: animation,
                child: RotationTransition(
                  turns: Tween(begin: -0.15, end: 0.0).animate(animation),
                  child: ScaleTransition(
                    // A slight overshoot gives the new icon a little pop.
                    scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    child: child,
                  ),
                ),
              ),
          child: LineIcon(glyph, key: ValueKey(glyph), color: iconColor),
        ),
      ),
    );
  }
}
