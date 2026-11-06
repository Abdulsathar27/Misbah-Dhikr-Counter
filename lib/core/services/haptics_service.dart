import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Device vibration. Abstracted so the BLoC can be tested without a platform.
abstract interface class HapticsService {
  /// A short buzz for each count.
  Future<void> tick();

  /// A firmer pulse for resets and for switching vibration back on.
  Future<void> confirm();

  /// A double pulse for reaching the goal, noticeable without looking.
  Future<void> goalReached();
}

/// Drives the vibration motor directly. System touch feedback
/// (`HapticFeedback`) was too faint and depended on the phone's touch settings.
/// The in-app toggle is what turns this off; platforms with no motor do nothing.
class DeviceHapticsService implements HapticsService {
  const DeviceHapticsService();

  @override
  Future<void> tick() => _guard(() => Vibration.vibrate(duration: 40, amplitude: 160));

  @override
  Future<void> confirm() => _guard(() => Vibration.vibrate(duration: 120, amplitude: 255));

  @override
  Future<void> goalReached() =>
      _guard(() => Vibration.vibrate(pattern: [0, 200, 120, 300], intensities: [0, 255, 0, 255]));

  Future<void> _guard(Future<void> Function() vibrate) async {
    try {
      await vibrate();
    } on PlatformException {
      // Vibration is best-effort; an unsupported device must not break counting.
    } on MissingPluginException {
      // Same as above, for platforms without a vibration implementation.
    }
  }
}
