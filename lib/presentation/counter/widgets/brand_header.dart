import 'package:flutter/widgets.dart';

import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

/// The centred, widely tracked MISBAH wordmark.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: AppConstants.brandName,
      excludeSemantics: true,
      child: Padding(
        // Letter spacing trails the last glyph too; pad the start by the same
        // amount so the word centres optically.
        padding: const EdgeInsetsDirectional.only(
          start: AppTypography.brandFontSize * AppTypography.brandLetterSpacingEm,
        ),
        child: Text(
          AppConstants.brandName.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppTypography.brand,
          maxLines: 1,
        ),
      ),
    );
  }
}
