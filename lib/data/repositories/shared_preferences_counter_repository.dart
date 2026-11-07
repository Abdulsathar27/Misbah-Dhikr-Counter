import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/counter_entity.dart';
import '../../domain/repositories/counter_repository.dart';

/// Keeps the settings in [SharedPreferences]. Only the settings are saved, so
/// the count always starts at 0.
class SharedPreferencesCounterRepository implements CounterRepository {
  const SharedPreferencesCounterRepository(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<CounterEntity> load() async {
    try {
      final vibrationEnabled = _preferences.getBool(StorageKeys.vibrationEnabled);
      final goal = _preferences.getInt(StorageKeys.goal);
      return CounterEntity(
        count: 0,
        vibrationEnabled: vibrationEnabled ?? CounterEntity.initial.vibrationEnabled,
        // Corrupt or hand-edited values must never produce an out-of-range
        // goal: a missing or out-of-range goal means none is set.
        goal:
            (goal == null || goal < AppConstants.minGoal || goal > AppConstants.maxGoal)
                ? null
                : goal,
      );
    } on Object catch (error) {
      // A key holding an unexpected type throws a TypeError.
      throw StorageException('Failed to read counter', error);
    }
  }

  @override
  Future<void> saveVibrationEnabled({required bool enabled}) async {
    final ok = await _preferences.setBool(StorageKeys.vibrationEnabled, enabled);
    if (!ok) throw const StorageException('Failed to write vibration preference');
  }

  @override
  Future<void> saveGoal(int? goal) async {
    final ok =
        goal == null
            ? await _preferences.remove(StorageKeys.goal)
            : await _preferences.setInt(StorageKeys.goal, goal);
    if (!ok) throw const StorageException('Failed to write goal');
  }
}
