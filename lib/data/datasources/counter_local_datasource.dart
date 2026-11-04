import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/counter_model.dart';

abstract interface class CounterLocalDataSource {
  Future<CounterModel> read();
  Future<void> writeCount(CounterModel model);
  Future<void> writeVibrationEnabled({required bool enabled});

  /// Saves [goal], or removes the saved goal when it is null.
  Future<void> writeGoal(int? goal);
}

class SharedPreferencesCounterDataSource implements CounterLocalDataSource {
  const SharedPreferencesCounterDataSource(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<CounterModel> read() async {
    try {
      return CounterModel.fromStorage(
        count: _preferences.getInt(StorageKeys.count),
        undoHistory: _preferences.getStringList(StorageKeys.undoHistory),
        vibrationEnabled: _preferences.getBool(StorageKeys.vibrationEnabled),
        goal: _preferences.getInt(StorageKeys.goal),
      );
    } on Object catch (error) {
      // A key holding an unexpected type throws a TypeError.
      throw StorageException('Failed to read counter', error);
    }
  }

  @override
  Future<void> writeCount(CounterModel model) async {
    final results = await Future.wait([
      _preferences.setInt(StorageKeys.count, model.count),
      _preferences.setStringList(StorageKeys.undoHistory, model.undoHistoryForStorage),
    ]);
    if (results.contains(false)) {
      throw const StorageException('Failed to write counter');
    }
  }

  @override
  Future<void> writeVibrationEnabled({required bool enabled}) async {
    final ok = await _preferences.setBool(StorageKeys.vibrationEnabled, enabled);
    if (!ok) throw const StorageException('Failed to write vibration preference');
  }

  @override
  Future<void> writeGoal(int? goal) async {
    final ok =
        goal == null
            ? await _preferences.remove(StorageKeys.goal)
            : await _preferences.setInt(StorageKeys.goal, goal);
    if (!ok) throw const StorageException('Failed to write goal');
  }
}
