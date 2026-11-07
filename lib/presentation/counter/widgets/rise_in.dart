import 'package:flutter/widgets.dart';

/// Fades [child] in as it rises a little, driven by [animation] (0 to 1).
class RiseIn extends StatelessWidget {
  const RiseIn({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.25), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}
