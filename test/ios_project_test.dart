import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// flutter_launcher_icons rewrites every project setting containing
/// "ASSETCATALOG", not only the icon name. This fails if a rerun does that, so
/// it is caught here rather than in an iOS build, which needs a Mac.
void main() {
  final project = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

  Set<String> valuesOf(String setting) =>
      RegExp('$setting = (.*);').allMatches(project).map((m) => m.group(1)!).toSet();

  test('the icon generator has not overwritten other iOS build settings', () {
    expect(valuesOf('ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS'), {'YES'});
  });

  test('the iOS app icon set is the one in the asset catalog', () {
    expect(valuesOf('ASSETCATALOG_COMPILER_APPICON_NAME'), {'AppIcon'});
    expect(Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset').existsSync(), isTrue);
  });
}
