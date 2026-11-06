import '../../domain/entities/counter_entity.dart';
import '../../domain/repositories/counter_repository.dart';
import '../datasources/counter_local_datasource.dart';

class CounterRepositoryImpl implements CounterRepository {
  const CounterRepositoryImpl(this._localDataSource);

  final CounterLocalDataSource _localDataSource;

  @override
  Future<CounterEntity> load() async => (await _localDataSource.read()).toEntity();

  @override
  Future<void> saveVibrationEnabled({required bool enabled}) =>
      _localDataSource.writeVibrationEnabled(enabled: enabled);

  @override
  Future<void> saveGoal(int? goal) => _localDataSource.writeGoal(goal);
}
