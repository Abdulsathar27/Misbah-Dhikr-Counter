import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_layout.dart';
import '../../shared/widgets/grow_with_screen.dart';
import '../widgets/about_button.dart';
import '../widgets/brand_header.dart';
import '../widgets/counter_controls.dart';
import '../widgets/counter_stage.dart';
import '../widgets/entrance_animation.dart';
import '../widgets/failure_listener.dart';
import '../widgets/goal_reached_listener.dart';

/// The single MISBAH screen: brand, progress ring, count button, controls.
/// Sections arrive one after another at launch. Gaps tighten on short
/// screens; everything grows on large ones (see [AppLayout]).
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = AppLayout.spacingOf(context);
    return FailureListener(
      child: GoalReachedListener(
        child: Scaffold(
          backgroundColor: AppColors.canvas,
          body: SafeArea(
            // CounterControls handles the bottom inset itself.
            bottom: false,
            // Keyboard focus reaches the counter and its controls before the
            // About button, which sits first on screen but matters least.
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Stack(
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppDimensions.screenTopPadding * spacing),
                        const EntranceAnimation(child: GrowWithScreen(child: BrandHeader())),
                        const Expanded(
                          child: EntranceAnimation(delay: 0.15, child: CounterStage()),
                        ),
                        const EntranceAnimation(delay: 0.3, child: CounterControls()),
                      ],
                    ),
                  ),
                  // In the empty top corner, so the layout below is unchanged.
                  const Positioned(
                    top: 4,
                    right: 4,
                    child: FocusTraversalOrder(
                      order: NumericFocusOrder(2),
                      child: EntranceAnimation(child: AboutButton()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
