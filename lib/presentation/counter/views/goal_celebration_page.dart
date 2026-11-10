import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../shared/widgets/grow_with_screen.dart';
import '../../shared/widgets/rise_in.dart';
import '../widgets/celebration_actions.dart';
import '../widgets/celebration_count_up.dart';
import '../widgets/celebration_emblem.dart';
import '../widgets/celebration_message.dart';
import '../widgets/goal_dialog.dart';

/// Celebrates reaching [goal] full-screen, then asks what comes next. It must
/// be answered: back does nothing, as counting stays stopped until then.
/// Returns a new goal, or `(goal: null)` to continue without one.
Future<GoalChoice?> showGoalCelebration(BuildContext context, {required int goal}) {
  return Navigator.of(context).push<GoalChoice>(
    PageRouteBuilder<GoalChoice>(
      transitionDuration: AppMotion.of(context, AppMotion.splashExit),
      pageBuilder: (_, _, _) => GoalCelebrationPage(goal: goal),
      transitionsBuilder:
          (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
    ),
  );
}

/// A spark pops and bursts into rays, the emblem grows out of it, the number
/// counts up to the goal, and the choices rise in. With reduced motion it all
/// appears at once. Stateful only to own the animation's timeline.
class GoalCelebrationPage extends StatefulWidget {
  const GoalCelebrationPage({super.key, required this.goal});

  final int goal;

  @override
  State<GoalCelebrationPage> createState() => _GoalCelebrationPageState();
}

class _GoalCelebrationPageState extends State<GoalCelebrationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.celebration,
  );
  bool _started = false;

  Animation<double> _phase(double begin, double end, [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _controller, curve: Interval(begin, end, curve: curve));

  late final Animation<double> _spark = _phase(0, 0.16, Curves.easeOutBack);
  late final Animation<double> _sparkFade = ReverseAnimation(_phase(0.26, 0.4));
  late final Animation<double> _rays = _phase(0.1, 0.72, Curves.linear);
  late final Animation<double> _emblem = _phase(0.26, 0.56);
  late final Animation<double> _emblemScale = _phase(0.26, 0.56, Curves.easeOutBack);
  late final Animation<double> _count = _phase(0.42, 0.72);
  late final Animation<double> _title = _phase(0.56, 0.76);
  late final Animation<double> _buttons = _phase(0.76, 0.96);

  /// Glow flares as the spark bursts, then settles behind the emblem.
  late final Animation<double> _glow = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0.55), weight: 70),
  ]).animate(_controller);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setNewGoal() async {
    final choice = await showGoalDialog(context, current: null);
    if (choice != null && mounted) Navigator.of(context).pop(choice);
  }

  void _continueWithoutGoal() => Navigator.of(context).pop<GoalChoice>((goal: null));

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [AppColors.emerald, AppColors.deepPine],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.celebrationPadding),
              // Keeps the buttons a comfortable width on tablets.
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppDimensions.celebrationMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        // Scales down on very small screens instead of overflowing.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: GrowWithScreen(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CelebrationEmblem(
                                  spark: _spark,
                                  sparkFade: _sparkFade,
                                  rays: _rays,
                                  glow: _glow,
                                  emblem: _emblem,
                                  emblemScale: _emblemScale,
                                ),
                                CelebrationCountUp(goal: widget.goal, animation: _count),
                                const SizedBox(height: AppDimensions.celebrationTextGap),
                                RiseIn(
                                  animation: _title,
                                  child: CelebrationMessage(goal: widget.goal),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Not tappable until visible, so a stray tap cannot choose
                      // an option nobody can see yet.
                      AnimatedBuilder(
                        animation: _buttons,
                        builder:
                            (context, child) =>
                                IgnorePointer(ignoring: _buttons.value < 1, child: child),
                        child: RiseIn(
                          animation: _buttons,
                          child: CelebrationActions(
                            onSetNewGoal: _setNewGoal,
                            onContinue: _continueWithoutGoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
