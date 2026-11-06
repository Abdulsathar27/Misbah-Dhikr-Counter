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

  test('restores the saved preference and goal in a new instance', () async {
    final writer = await _repository();
    await writer.saveVibrationEnabled(enabled: false);
    await writer.saveGoal(33);

    // A fresh repository over the same storage simulates an app restart.
    final reader = await _repository();

    expect(await reader.load(), const CounterEntity(count: 0, vibrationEnabled: false, goal: 33));
  });

  test('a restart starts at zero, ignoring a count saved by an older version', () async {
    SharedPreferences.setMockInitialValues({
      'counter.count': 29,
      'counter.undo_history': ['27', '28'],
    });
    final loaded = await (await _repository()).load();

    expect(loaded.count, 0);
    expect(loaded.undoHistory, isEmpty);
  });

  test('removing the goal clears it from storage', () async {
    final writer = await _repository();
    await writer.saveGoal(33);
    await writer.saveGoal(null);

    expect((await _repository()).load().then((c) => c.goal), completion(isNull));
  });

  test('sanitises a corrupt stored goal', () async {
    SharedPreferences.setMockInitialValues({StorageKeys.goal: 0});
    final loaded = await (await _repository()).load();

    expect(loaded.vibrationEnabled, isTrue);
    expect(loaded.goal, isNull);
  });
}
