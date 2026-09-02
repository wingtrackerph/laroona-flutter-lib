// Loading skeletons.
//
// A skeleton earns its place by looking like the thing it stands in for, so
// these are primitives — a bone and a shimmer — rather than a finished
// placeholder. Each app composes the shapes its own cards need and hands the
// result to `DataListView(skeleton: ...)`.

import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';

/// What a single bone stands in for.
enum SkeletonBoneShape {
  /// A line of text.
  line,

  /// A card, a thumbnail, a chip — anything rectangular with card corners.
  box,

  /// An avatar.
  circle,
}

/// The colour a bone is painted in, from `ThemeColors` so light and dark both
/// look right. Never a hardcoded hex, and never a Material grey.
Color skeletonBaseColor(BuildContext context) =>
    ThemeColors.getStone300Color(context);

/// The colour the shimmer sweeps across the bones.
///
/// Lighter than the base in both themes — a highlight that went darker in dark
/// mode would read as a hole rather than a sweep — and mixed from `ThemeColors`
/// rather than written out as a hex.
Color skeletonHighlightColor(BuildContext context) {
  final Color base = skeletonBaseColor(context);

  return ThemeColors.isDark(context)
      ? Color.lerp(base, ThemeColors.getGrayTextColor(context), 0.25)!
      : Color.lerp(base, ThemeColors.getCardColor(context), 0.6)!;
}

/// The default height of a text-line bone.
const double skeletonLineHeight = 12;

/// The default height of a block bone.
const double skeletonBoxHeight = 80;

/// The default diameter of an avatar bone.
const double skeletonCircleSize = 44;

/// One piece of the shape of what is coming.
///
/// Paints through a `BoxDecoration` so its colour and its shape are readable
/// from the widget tree as well as from the screen.
class SkeletonBone extends StatelessWidget {
  const SkeletonBone({
    super.key,
    this.shape = SkeletonBoneShape.line,
    this.width,
    this.height,
  });

  final SkeletonBoneShape shape;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bool isCircle = shape == SkeletonBoneShape.circle;

    final double? resolvedWidth = isCircle
        ? (width ?? height ?? skeletonCircleSize)
        : width;
    final double resolvedHeight = isCircle
        ? (height ?? width ?? skeletonCircleSize)
        : (height ??
              (shape == SkeletonBoneShape.line
                  ? skeletonLineHeight
                  : skeletonBoxHeight));

    return Container(
      width: resolvedWidth,
      height: resolvedHeight,
      decoration: BoxDecoration(
        color: skeletonBaseColor(context),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        // The stand-in has the same corners as the thing it stands in for.
        borderRadius: isCircle
            ? null
            : BorderRadius.circular(
                shape == SkeletonBoneShape.line ? radiusSizeSmall : radiusSize,
              ),
      ),
    );
  }
}

/// The shimmer host: ONE `AnimationController` per skeleton subtree, sweeping
/// a single gradient across every bone underneath it together.
///
/// Respects `MediaQuery.disableAnimations` — the "reduce motion" switch gets
/// static bones, not no bones.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  static const Duration _sweep = Duration(milliseconds: 1400);

  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool motionAllowed =
        !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);

    if (motionAllowed && _controller == null) {
      _controller = AnimationController(vsync: this, duration: _sweep)
        ..repeat();
      return;
    }

    if (!motionAllowed && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController? controller = _controller;

    if (controller == null) {
      return widget.child;
    }

    final Color base = skeletonBaseColor(context);
    final Color highlight = skeletonHighlightColor(context);

    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        // -1 -> 1: the band travels from off the left edge to off the right.
        final double travel = controller.value * 3 - 1.5;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) => LinearGradient(
            begin: Alignment(travel - 0.6, -0.4),
            end: Alignment(travel + 0.6, 0.4),
            colors: <Color>[base, highlight, base],
            stops: const <double>[0, 0.5, 1],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}
