abstract final class AppConstants {
  static const String appTitle = 'MISBAH';
  static const String brandName = 'Misbah';

  /// How many previous values are kept so that undo can step back through
  /// increments and resets. Older entries are discarded.
  static const int undoHistoryLimit = 100;

  /// The goal the ring fills towards until the user sets their own.
  static const int defaultGoal = 10;
  static const int minGoal = 1;
  static const int maxGoal = 99999;
}

abstract final class StorageKeys {
  static const String count = 'counter.count';
  static const String undoHistory = 'counter.undo_history';
  static const String vibrationEnabled = 'counter.vibration_enabled';
  static const String goal = 'counter.goal';
}
