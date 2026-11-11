abstract final class AppConstants {
  static const String appTitle = 'MISBAH';
  static const String brandName = 'Misbah';
  static const String tagline = 'Count Your Dhikr. Connect Your Heart';

  /// Published from docs/ on the main branch with GitHub Pages.
  static const String privacyPolicyUrl =
      'https://abdulsathar27.github.io/Misbah-Dhikr-Counter/privacy-policy.html';

  /// The range a user-set goal must fall in. There is no default goal.
  static const int minGoal = 1;
  static const int maxGoal = 99999;
}

abstract final class StorageKeys {
  static const String vibrationEnabled = 'counter.vibration_enabled';
  static const String goal = 'counter.goal';
}
