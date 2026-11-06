import '../entities/counter_entity.dart';

/// Contract for loading and saving the counter.
abstract interface class CounterRepository {
  /// Returns the saved settings with the count at 0, as every launch starts a
  /// new count. Throws a `StorageException` if storage is unreadable.
  Future<CounterEntity> load();

  /// Saves the vibration preference.
  Future<void> saveVibrationEnabled({required bool enabled});

  /// Saves the goal the progress ring fills towards; null removes it.
  Future<void> saveGoal(int? goal);
}
