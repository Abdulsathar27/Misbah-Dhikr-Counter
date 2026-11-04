import 'package:counter/core/constants/app_constants.dart';
import 'package:counter/data/datasources/counter_local_datasource.dart';
import 'package:counter/data/repositories/counter_repository_impl.dart';
import 'package:counter/domain/entities/counter_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<CounterRepositoryImpl> _repository() async {
  final prefs = await SharedPreferences.getInstance();
  return CounterRepositoryImpl(SharedPreferencesCounterDataSource(prefs));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('loads defaults when nothing has been saved', () async {
    final repository = await _repository();

    expect(await repository.load(), CounterEntity.initial);
  });

  test('restores a saved count, history, preference and goal in a new instance', () async {
    final writer = await _repository();
    await writer.saveCount(const CounterEntity(count: 12, undoHistory: [10, 11]));
    await writer.saveVibrationEnabled(enabled: false);
    await writer.saveGoal(33);

    // A fresh repository over the same storage simulates an app restart.
    final reader = await _repository();

    expect(
      await reader.load(),
      const CounterEntity(count: 12, undoHistory: [10, 11], vibrationEnabled: false, goal: 33),
    );
  });

  test('removing the goal clears it from storage', () async {
    final writer = await _repository();
    await writer.saveGoal(33);
    await writer.saveGoal(null);

    expect((await _repository()).load().then((c) => c.goal), completion(isNull));
  });

  test('sanitises corrupt stored values instead of going negative', () async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.count: -5,
      StorageKeys.undoHistory: ['3', 'oops', '-1', '4'],
      StorageKeys.goal: 0,
    });
    final repository = await _repository();

    final loaded = await repository.load();

    expect(loaded.count, 0);
    expect(loaded.undoHistory, [3, 4]);
    expect(loaded.vibrationEnabled, isTrue);
    expect(loaded.goal, isNull);
  });
}
