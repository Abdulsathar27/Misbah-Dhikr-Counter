import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'about_sheet.dart';

/// A quiet info button that opens [AboutSheet], which links to the privacy
/// policy. Kept in the top corner, out of the way of counting.
class AboutButton extends StatelessWidget {
  const AboutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showAboutSheet(context),
      tooltip: 'About and privacy',
      icon: const Icon(Icons.info_outline, size: 22, color: AppColors.secondary),
    );
  }
}
