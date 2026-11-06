import '../../core/constants/app_constants.dart';
import '../../domain/entities/counter_entity.dart';

/// What is kept in storage: the settings. Only the settings are saved, so the
/// count always starts at 0. Sanitises whatever was on disk so corrupt or
/// hand-edited values can never produce an out-of-range goal.
class CounterModel extends CounterEntity {
  const CounterModel({super.vibrationEnabled, super.goal}) : super(count: 0);

  factory CounterModel.fromStorage({required bool? vibrationEnabled, required int? goal}) {
    return CounterModel(
      vibrationEnabled: vibrationEnabled ?? CounterEntity.initial.vibrationEnabled,
      // A missing or out-of-range goal means none is set.
      goal:
          (goal == null || goal < AppConstants.minGoal || goal > AppConstants.maxGoal)
              ? null
              : goal,
    );
  }

  CounterEntity toEntity() =>
      CounterEntity(count: count, vibrationEnabled: vibrationEnabled, goal: goal);
}
