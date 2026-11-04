import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/counter_bloc.dart';

/// Shows each new persistence failure in a snack bar, including one that was
/// already there when the screen opened (the bloc loads before the first
/// frame, and BlocListener never reports the initial state).
class FailureListener extends StatefulWidget {
  const FailureListener({super.key, required this.child});

  final Widget child;

  @override
  State<FailureListener> createState() => _FailureListenerState();
}

class _FailureListenerState extends State<FailureListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final failure = context.read<CounterBloc>().state.failure;
      if (failure != null) _show(failure.message);
    });
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterBloc, CounterState>(
      listenWhen:
          (previous, current) => current.failure != null && previous.failure != current.failure,
      listener: (context, state) => _show(state.failure!.message),
      child: widget.child,
    );
  }
}
