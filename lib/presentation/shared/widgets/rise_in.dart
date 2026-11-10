import 'package:flutter/widgets.dart';

/// Fades [child] in as it rises into place, driven by [animation] (0 to 1).
/// [rise] is how far below its place it starts, as a share of its height.
class RiseIn extends StatelessWidget {
  const RiseIn({super.key, required this.animation, required this.child, this.rise = 0.25});

  final Animation<double> animation;
  final Widget child;
  final double rise;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: Offset(0, rise), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}
