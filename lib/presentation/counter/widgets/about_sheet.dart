import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

/// Opens the full privacy policy in the browser. Returns false if it could
/// not be opened. Replaceable in tests.
typedef LinkOpener = Future<bool> Function(Uri uri);

Future<bool> _openInBrowser(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

/// Shows what MISBAH is and how it treats your data, with a link to the full
/// privacy policy. Google Play requires the policy to be reachable from inside
/// the app, not only from the store listing.
Future<void> showAboutSheet(BuildContext context, {LinkOpener openLink = _openInBrowser}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => AboutSheet(openLink: openLink),
  );
}

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key, this.openLink = _openInBrowser});

  final LinkOpener openLink;

  Future<void> _openPolicy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await openLink(Uri.parse(AppConstants.privacyPolicyUrl));
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the privacy policy. The link is shown below.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                AppConstants.brandName.toUpperCase(),
                style: AppTypography.brand.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 4),
            const Text(AppConstants.tagline, style: AppTypography.tagline),
            const SizedBox(height: 20),
            const Text(
              'Your privacy',
              style: TextStyle(
                fontFamily: AppTypography.bodyFamily,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Misbah works fully offline. It does not collect, store on any server or share '
              'any personal data, and it has no ads or accounts. Only your goal and '
              'vibration setting are saved, on this phone.',
              style: TextStyle(
                fontFamily: AppTypography.bodyFamily,
                fontSize: 15,
                height: 1.5,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _openPolicy(context),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Read the full privacy policy'),
            ),
            const SelectableText(
              AppConstants.privacyPolicyUrl,
              style: TextStyle(
                fontFamily: AppTypography.bodyFamily,
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
