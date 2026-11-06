import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

/// The round raised button used for counting and for the bottom controls:
/// hairline border, soft shadow, a press-down that shrinks it slightly, a
/// keyboard focus ring, dimming when disabled, and a single semantics node.
class DiscButton extends StatefulWidget {
  const DiscButton({
    super.key,
    required this.size,
    required this.semanticLabel,
    required this.onPressed,
    required this.child,
    this.toggled,
    this.onPressStart,
  });

  final double size;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Widget child;

  /// Non-null for toggle buttons; exposed to assistive tech as pressed state.
  final bool? toggled;

  /// Where a press began, in local coordinates (the centre for keyboard use).
  final ValueChanged<Offset>? onPressStart;

  @override
  State<DiscButton> createState() => _DiscButtonState();
}

class _DiscButtonState extends State<DiscButton> {
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _activate() {
    widget.onPressStart?.call(Offset(widget.size / 2, widget.size / 2));
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate())},
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown:
              _enabled
                  ? (details) {
                    _setPressed(true);
                    widget.onPressStart?.call(details.localPosition);
                  }
                  : null,
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed,
          child: AnimatedOpacity(
            opacity: _enabled ? 1 : 0.4,
            duration: AppMotion.of(context, AppMotion.press),
            child: _Disc(
              size: widget.size,
              pressed: _pressed,
              focused: _focused,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _Disc extends StatelessWidget {
  const _Disc({
    required this.size,
    required this.pressed,
    required this.focused,
    required this.child,
  });

  final double size;
  final bool pressed;
  final bool focused;
  final Widget child;

  static const double _ringInset =
      -(AppDimensions.controlFocusOffset + AppDimensions.focusRingWidth);

  static const _restingShadow = BoxShadow(
    color: AppColors.controlShadow,
    offset: Offset(0, 10),
    blurRadius: 22,
    spreadRadius: -10,
  );

  static const _pressedShadow = BoxShadow(
    color: AppColors.controlShadowPressed,
    offset: Offset(0, 4),
    blurRadius: 10,
    spreadRadius: -6,
  );

  @override
  Widget build(BuildContext context) {
    final scale = pressed ? 0.95 : 1.0;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.press),
          curve: AppMotion.pressCurve,
          width: size,
          height: size,
          transformAlignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scale, scale, 1)
            ..setTranslationRaw(0, pressed ? 1 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
            boxShadow: [pressed ? _pressedShadow : _restingShadow],
          ),
          child: child,
        ),
        if (focused)
          const Positioned(
            left: _ringInset,
            top: _ringInset,
            right: _ringInset,
            bottom: _ringInset,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.accent, width: AppDimensions.focusRingWidth),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
