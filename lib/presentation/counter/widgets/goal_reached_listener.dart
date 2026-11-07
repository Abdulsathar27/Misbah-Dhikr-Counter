import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_dimensions.dart';
import '../bloc/counter_bloc.dart';
import '../views/goal_celebration_page.dart';

/// Celebrates and asks what comes next whenever the goal is reached.
class GoalReachedListener extends StatefulWidget {
  const GoalReachedListener({super.key, required this.child});

  final Widget child;

  @override
  State<GoalReachedListener> createState() => _GoalReachedListenerState();
}

class _GoalReachedListenerState extends State<GoalReachedListener> {
  bool _asking = false;

  /// Lets the ring finish filling, so the full ring is seen before the celebration.
  Future<void> _askAfterRingFills() async {
    await Future<void>.delayed(AppMotion.of(context, AppMotion.ring));
    if (mounted) await _ask();
  }

  Future<void> _ask() async {
    final bloc = context.read<CounterBloc>();
    final goal = bloc.state.goal;
    if (_asking || !bloc.state.goalReached || goal == null) return;
    _asking = true;
    final choice = await showGoalCelebration(context, goal: goal);
    _asking = false;
    if (choice == null) return;
    // Every choice starts a new round from 0. The count resets first, so the
    // new goal never applies to the old count.
    bloc
      ..add(const CounterResetRequested())
      ..add(CounterGoalChanged(choice.goal));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterBloc, CounterState>(
      listenWhen: (previous, current) => !previous.goalReached && current.goalReached,
      listener: (_, _) => _askAfterRingFills(),
      child: widget.child,
    );
  }
}
