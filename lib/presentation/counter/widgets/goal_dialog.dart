import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';

/// What the user chose in the goal dialog: a new goal, or null to remove it.
typedef GoalChoice = ({int? goal});

/// Asks for a goal. [current] is null when none is set; the dialog then
/// starts empty. Returns the choice, or null when the dialog is cancelled.
Future<GoalChoice?> showGoalDialog(BuildContext context, {required int? current}) {
  return showDialog<GoalChoice>(context: context, builder: (_) => _GoalDialog(current: current));
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.current});

  final int? current;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final TextEditingController _controller = () {
    final text = widget.current?.toString() ?? '';
    return TextEditingController(text: text)
      ..selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }();

  int? get _goal {
    final value = int.tryParse(_controller.text);
    if (value == null || value < AppConstants.minGoal || value > AppConstants.maxGoal) return null;
    return value;
  }

  void _close(GoalChoice? choice) => Navigator.of(context).pop(choice);

  void _submit() {
    final goal = _goal;
    if (goal != null) _close((goal: goal));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set goal'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter('${AppConstants.maxGoal}'.length),
        ],
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(hintText: 'e.g. 33'),
      ),
      actions: [
        if (widget.current != null)
          TextButton(onPressed: () => _close((goal: null)), child: const Text('Remove')),
        TextButton(onPressed: () => _close(null), child: const Text('Cancel')),
        TextButton(onPressed: _goal == null ? null : _submit, child: const Text('Save')),
      ],
    );
  }
}
