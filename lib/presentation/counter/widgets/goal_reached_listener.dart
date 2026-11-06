import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_dimensions.dart';
import '../bloc/counter_bloc.dart';
import 'goal_dialog.dart';
import 'goal_reached_dialog.dart';

/// Asks what comes next whenever the goal is reached, including when the app
/// opens on a goal that was already reached.
class GoalReachedListener extends StatefulWidget {
  const GoalReachedListener({super.key, required this.child});

  final Widget child;

  @override
  State<GoalReachedListener> createState() => _GoalReachedListenerState();
}

class _GoalReachedListenerState extends State<GoalReachedListener> {
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<CounterBloc>().state.goalReached) _ask();
    });
  }

  /// Lets the ring finish filling, so the full ring is seen before the dialog.
  Future<void> _askAfterRingFills() async {
    await Future<void>.delayed(AppMotion.of(context, AppMotion.ring));
    if (mounted) await _ask();
  }

  Future<void> _ask() async {
    final bloc = context.read<CounterBloc>();
    final goal = bloc.state.goal;
    if (_asking || !bloc.state.goalReached || goal == null) return;
    _asking = true;

    // Cancelling the new-goal dialog comes back here: a choice is still needed.
    while (true) {
      if (!mounted) return;
      final choice = await showGoalReachedDialog(context, goal: goal);
      if (!mounted) return;
      if (choice == GoalReachedChoice.continueWithoutGoal) {
        _startAgain(bloc, goal: null);
        break;
      }
      final newGoal = (await showGoalDialog(context, current: null))?.goal;
      if (newGoal != null) {
        _startAgain(bloc, goal: newGoal);
        break;
      }
    }
    _asking = false;
  }

  /// Every choice starts a new round from 0. The count resets first, so the
  /// new goal never applies to the old count.
  void _startAgain(CounterBloc bloc, {required int? goal}) {
    bloc
      ..add(const CounterResetRequested())
      ..add(CounterGoalChanged(goal));
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
