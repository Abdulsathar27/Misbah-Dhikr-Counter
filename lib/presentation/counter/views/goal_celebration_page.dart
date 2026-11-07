import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_typography.dart';
import '../../splash/widgets/splash_mark.dart';
import '../widgets/celebration_burst.dart';
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    // Scales down on very small screens instead of overflowing.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CelebrationEmblem(
                            spark: _spark,
                            sparkFade: _sparkFade,
                            rays: _rays,
                            glow: _glow,
                            emblem: _emblem,
                            emblemScale: _emblemScale,
                          ),
                          _CountUp(goal: widget.goal, animation: _count),
                          const SizedBox(height: AppDimensions.celebrationTextGap),
                          _RiseIn(
                            animation: _title,
                            child: _CelebrationMessage(goal: widget.goal),
                          ),
                        ],
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
                    child: _RiseIn(
                      animation: _buttons,
                      child: _CelebrationActions(
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
    );
  }
}

/// The burst with the spark at its centre, and the emblem that grows from it.
class _CelebrationEmblem extends StatelessWidget {
  const _CelebrationEmblem({
    required this.spark,
    required this.sparkFade,
    required this.rays,
    required this.glow,
    required this.emblem,
    required this.emblemScale,
  });

  final Animation<double> spark;
  final Animation<double> sparkFade;
  final Animation<double> rays;
  final Animation<double> glow;
  final Animation<double> emblem;
  final Animation<double> emblemScale;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppDimensions.celebrationStageSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CelebrationBurst(rays: rays, glow: glow)),
          ScaleTransition(
            scale: Tween(begin: 0.3, end: AppDimensions.celebrationEmblemScale).animate(emblemScale),
            child: FadeTransition(opacity: emblem, child: SplashMark(progress: emblem)),
          ),
          FadeTransition(
            opacity: sparkFade,
            child: ScaleTransition(scale: spark, child: const _Spark()),
          ),
        ],
      ),
    );
  }
}

/// The small glowing gold orb the burst starts from.
class _Spark extends StatelessWidget {
  const _Spark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: AppDimensions.celebrationSparkSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.35),
            colors: [AppColors.cream, AppColors.lampGold],
          ),
          boxShadow: [BoxShadow(color: AppColors.lampGold, blurRadius: 28, spreadRadius: 4)],
        ),
      ),
    );
  }
}

/// The number rolling up from 0 to the goal.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.goal, required this.animation});

  final int goal;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder:
          (context, _) => Text(
            '${(goal * animation.value).round()}',
            maxLines: 1,
            style: AppTypography.celebrationCount,
            textScaler: TextScaler.noScaling,
          ),
    );
  }
}

class _CelebrationMessage extends StatelessWidget {
  const _CelebrationMessage({required this.goal});

  final int goal;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          liveRegion: true,
          child: const Text('Goal complete!', style: AppTypography.celebrationTitle),
        ),
        const SizedBox(height: AppDimensions.splashTaglineGap),
        Text('You reached your goal of $goal', style: AppTypography.tagline),
      ],
    );
  }
}

class _CelebrationActions extends StatelessWidget {
  const _CelebrationActions({required this.onSetNewGoal, required this.onContinue});

  final VoidCallback onSetNewGoal;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A darker lip under the pill gives the button a raised, tactile edge.
        DecoratedBox(
          decoration: const ShapeDecoration(
            shape: StadiumBorder(),
            shadows: [BoxShadow(color: AppColors.lampGoldShade, offset: Offset(0, 4))],
          ),
          child: FilledButton(
            onPressed: onSetNewGoal,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              minimumSize: const Size.fromHeight(AppDimensions.celebrationButtonHeight),
              shape: const StadiumBorder(),
              textStyle: AppTypography.celebrationButton,
            ),
            child: const Text('Set new goal'),
          ),
        ),
        const SizedBox(height: AppDimensions.celebrationTextGap),
        TextButton(
          onPressed: onContinue,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.foreground,
            textStyle: AppTypography.celebrationButton,
          ),
          child: const Text('Continue without goal'),
        ),
      ],
    );
  }
}

/// Fades [child] in as it rises a little.
class _RiseIn extends StatelessWidget {
  const _RiseIn({required this.animation, required this.child});

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
