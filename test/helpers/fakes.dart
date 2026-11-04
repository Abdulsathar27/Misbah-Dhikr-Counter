import 'package:counter/core/errors/exceptions.dart';
import 'package:counter/core/services/haptics_service.dart';
import 'package:counter/domain/entities/counter_entity.dart';
import 'package:counter/domain/repositories/counter_repository.dart';

/// In-memory repository that records what was saved.
class FakeCounterRepository implements CounterRepository {
  FakeCounterRepository([this.stored = CounterEntity.initial]);

  CounterEntity stored;
  bool failLoad = false;
  bool failSave = false;
  int saveCountCalls = 0;

  @override
  Future<CounterEntity> load() async {
    if (failLoad) throw const StorageException('load failed');
    return stored;
  }

  @override
  Future<void> saveCount(CounterEntity counter) async {
    saveCountCalls++;
    if (failSave) throw const StorageException('save failed');
    stored = stored.copyWith(count: counter.count, undoHistory: counter.undoHistory);
  }

  @override
  Future<void> saveVibrationEnabled({required bool enabled}) async {
    if (failSave) throw const StorageException('save failed');
    stored = stored.copyWith(vibrationEnabled: enabled);
  }

  @override
  Future<void> saveGoal(int? goal) async {
    if (failSave) throw const StorageException('save failed');
    stored = stored.copyWith(goal: () => goal);
  }
}

class FakeHapticsService implements HapticsService {
  int ticks = 0;
  int confirms = 0;

  @override
  Future<void> tick() async => ticks++;

  @override
  Future<void> confirm() async => confirms++;
}
