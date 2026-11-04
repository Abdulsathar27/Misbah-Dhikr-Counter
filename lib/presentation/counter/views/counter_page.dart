import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../widgets/brand_header.dart';
import '../widgets/counter_controls.dart';
import '../widgets/counter_stage.dart';
import '../widgets/entrance_animation.dart';
import '../widgets/failure_listener.dart';

/// The single MUSMILES screen: brand, progress ring, count button, controls.
/// Sections arrive one after another at launch.
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FailureListener(
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          // CounterControls handles the bottom inset itself.
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppDimensions.screenTopPadding),
              EntranceAnimation(child: BrandHeader()),
              Expanded(child: EntranceAnimation(delay: 0.15, child: CounterStage())),
              EntranceAnimation(delay: 0.3, child: CounterControls()),
            ],
          ),
        ),
      ),
    );
  }
}
