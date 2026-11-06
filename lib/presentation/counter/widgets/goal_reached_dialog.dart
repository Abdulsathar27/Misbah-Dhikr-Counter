import 'package:flutter/material.dart';

/// What to do after reaching a goal.
enum GoalReachedChoice { setNewGoal, continueWithoutGoal }

/// Asks what comes next after reaching [goal]. It must be answered: counting
/// stays stopped until then, so tapping outside or pressing back does nothing.
Future<GoalReachedChoice?> showGoalReachedDialog(BuildContext context, {required int goal}) {
  return showDialog<GoalReachedChoice>(
    context: context,
    barrierDismissible: false,
    builder: (_) => GoalReachedDialog(goal: goal),
  );
}

class GoalReachedDialog extends StatelessWidget {
  const GoalReachedDialog({super.key, required this.goal});

  final int goal;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Goal reached'),
        content: Text(
          'You reached your goal of $goal. Set a new goal or continue without one. '
          'Either way, the count starts again from 0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(GoalReachedChoice.continueWithoutGoal),
            child: const Text('Continue without goal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(GoalReachedChoice.setNewGoal),
            child: const Text('Set new goal'),
          ),
        ],
      ),
    );
  }
}
