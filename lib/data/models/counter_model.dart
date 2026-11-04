import '../../core/constants/app_constants.dart';
import '../../domain/entities/counter_entity.dart';

/// Storage representation of [CounterEntity]. Sanitises whatever was on disk
/// so corrupt or hand-edited values can never produce a negative count or an
/// out-of-range goal.
class CounterModel extends CounterEntity {
  const CounterModel({required super.count, super.undoHistory, super.vibrationEnabled, super.goal});

  factory CounterModel.fromEntity(CounterEntity entity) => CounterModel(
    count: entity.count,
    undoHistory: entity.undoHistory,
    vibrationEnabled: entity.vibrationEnabled,
    goal: entity.goal,
  );

  factory CounterModel.fromStorage({
    required int? count,
    required List<String>? undoHistory,
    required bool? vibrationEnabled,
    required int? goal,
  }) {
    final safeCount = (count == null || count < 0) ? 0 : count;
    final safeHistory = <int>[
      for (final raw in undoHistory ?? const <String>[])
        if (int.tryParse(raw) case final value? when value >= 0) value,
    ];
    return CounterModel(
      count: safeCount,
      undoHistory: List.unmodifiable(safeHistory),
      vibrationEnabled: vibrationEnabled ?? CounterEntity.initial.vibrationEnabled,
      // A missing or out-of-range goal means none is set.
      goal:
          (goal == null || goal < AppConstants.minGoal || goal > AppConstants.maxGoal)
              ? null
              : goal,
    );
  }

  CounterEntity toEntity() => CounterEntity(
    count: count,
    undoHistory: undoHistory,
    vibrationEnabled: vibrationEnabled,
    goal: goal,
  );

  List<String> get undoHistoryForStorage => [for (final value in undoHistory) '$value'];
}
