import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../app/theme/app_layout.dart';

/// Draws [child] larger on screens bigger than the design, keeping its
/// proportions; see [AppLayout.growthOf]. Unlike a plain transform, it takes
/// up the larger space in the layout, and taps land where they are drawn.
///
/// At the design size and below it changes nothing. Wrap it in a
/// `FittedBox(fit: BoxFit.scaleDown)` where space can run out.
class GrowWithScreen extends StatelessWidget {
  const GrowWithScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => _Scaled(scale: AppLayout.growthOf(context), child: child);
}

class _Scaled extends SingleChildRenderObjectWidget {
  const _Scaled({required this.scale, super.child});

  final double scale;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderScaled(scale);

  @override
  void updateRenderObject(BuildContext context, _RenderScaled renderObject) {
    renderObject.scale = scale;
  }
}

/// Lays the child out in 1/[scale] of the space, then paints and hit-tests it
/// [scale] times larger, so it fills exactly the space it was given.
class _RenderScaled extends RenderProxyBox {
  _RenderScaled(this._scale);

  double _scale;

  set scale(double value) {
    if (value == _scale) return;
    _scale = value;
    markNeedsLayout();
  }

  Matrix4 get _transform => Matrix4.diagonal3Values(_scale, _scale, 1);

  BoxConstraints _childConstraints(BoxConstraints constraints) => BoxConstraints(
    minWidth: constraints.minWidth / _scale,
    maxWidth: constraints.maxWidth / _scale,
    minHeight: constraints.minHeight / _scale,
    maxHeight: constraints.maxHeight / _scale,
  );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return constraints.constrain(child.getDryLayout(_childConstraints(constraints)) * _scale);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    size = constraints.constrain(child.size * _scale);
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      (child?.getMinIntrinsicWidth(height / _scale) ?? 0) * _scale;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      (child?.getMaxIntrinsicWidth(height / _scale) ?? 0) * _scale;

  @override
  double computeMinIntrinsicHeight(double width) =>
      (child?.getMinIntrinsicHeight(width / _scale) ?? 0) * _scale;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      (child?.getMaxIntrinsicHeight(width / _scale) ?? 0) * _scale;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    if (_scale == 1) {
      layer = null;
      super.paint(context, offset);
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      super.paint,
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      result.addWithPaintTransform(
        transform: _transform,
        position: position,
        hitTest: (result, position) => super.hitTestChildren(result, position: position),
      );

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) => transform.multiply(_transform);
}
