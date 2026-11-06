import 'package:counter/core/errors/exceptions.dart';
import 'package:counter/core/services/haptics_service.dart';
import 'package:counter/domain/entities/counter_entity.dart';
import 'package:counter/domain/repositories/counter_repository.dart';

/// In-memory repository that records what was saved. [stored] is what `load`
/// returns, so tests can also start from any count.
class FakeCounterRepository implements CounterRepository {
  FakeCounterRepository([this.stored = CounterEntity.initial]);

  CounterEntity stored;
  bool failLoad = false;
  bool failSave = false;

  @override
  Future<CounterEntity> load() async {
    if (failLoad) throw const StorageException('load failed');
    return stored;
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
  int goalsReached = 0;

  @override
  Future<void> tick() async => ticks++;

  @override
  Future<void> confirm() async => confirms++;

  @override
  Future<void> goalReached() async => goalsReached++;
}
