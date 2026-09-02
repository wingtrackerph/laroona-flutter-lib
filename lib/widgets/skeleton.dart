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

// ---------------------------------------------------------------------------
// THE RULE — when a component shows the shape of what is coming.
//
// Pure: no BuildContext, no I/O, no provider. It lives beside the bones so an
// app never has to re-derive "is this a first load or a refresh?".
// ---------------------------------------------------------------------------

/// The row height a list stand-in assumes when it is not told otherwise: one
/// card with an avatar, two lines of text and its margin.
const double defaultSkeletonItemHeight = 96;

/// Never fewer than one bone: zero bones is a blank screen, which is worse
/// than the spinner this loop removes.
const int minSkeletonBones = 1;

/// Never more than this many: a huge viewport must not build hundreds of
/// animated bones.
const int maxSkeletonBones = 12;

/// The count used when the viewport has not been measured yet.
const int unmeasuredSkeletonBones = 3;

/// Whether [requestKey]-style request state means "show bones".
///
/// FIRST LOAD ONLY. A skeleton never replaces content the customer can already
/// see, so:
///
/// * anything already in hand ([hasData]) wins — a fetch in flight over a list
///   that is already on screen is a refresh, and the list stays;
/// * a request that is [isDone] with nothing in it has been answered with
///   "there is nothing", which belongs to the friendly empty state;
/// * everything else — loading with nothing yet, or not even asked yet — is a
///   first load, and a first load gets the shape of what is coming.
///
/// [isLoading] is part of the contract because callers read it off `Request`
/// and because it names the case this rule exists for; the answer is fixed by
/// the two facts above whether or not a fetch is currently in flight.
bool showSkeleton({
  required bool isLoading,
  required bool isDone,
  required bool hasData,
}) {
  if (hasData) {
    // THE REFRESH RULE. Covering content the customer can already read is the
    // one way this refactor makes the app feel slower.
    return false;
  }

  if (isDone) {
    // Answered, and the answer was "nothing". The empty state's job.
    return false;
  }

  // Loading with nothing to show, or not asked yet: the first load. Both
  // spellings of that — `isLoading` true, or a request that has not been sent —
  // show the shape of what is coming.
  return true;
}

/// How many shaped rows it takes to fill [height] with rows of [itemHeight].
///
/// So a list stand-in fills the viewport without any screen hard-coding a
/// count, and so a short strip does not pretend to be a full page.
int bonesForHeight(
  double height, {
  double itemHeight = defaultSkeletonItemHeight,
}) {
  final double rowHeight = itemHeight.isFinite && itemHeight > 0
      ? itemHeight
      : defaultSkeletonItemHeight;

  if (!height.isFinite || height <= 0) {
    // Nonsense or not-yet-laid-out input is not a reason to render nothing.
    return unmeasuredSkeletonBones;
  }

  final int count = (height / rowHeight).ceil();

  return count.clamp(minSkeletonBones, maxSkeletonBones);
}

// ---------------------------------------------------------------------------
// COMPOSITION — the shapes every app needs, whatever its domain.
//
// The DOMAIN shapes (a booking card, a worker row) stay in the app: only the
// app knows what its own cards look like. What generalises is the scaffolding
// they are built from.
// ---------------------------------------------------------------------------

/// A card-shaped surround, matching `AppCard`'s corners and margins.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: paddingSizeXXSmall),
      padding: const EdgeInsets.all(paddingSizeSmall),
      decoration: BoxDecoration(
        color: ThemeColors.getCardColor(context),
        borderRadius: BorderRadius.circular(radiusSize),
      ),
      child: child,
    );
  }
}

/// N stacked rows, as many as the viewport has room for.
///
/// The count comes from [bonesForHeight] so no screen hard-codes one, and the
/// rows live in a non-scrolling `ListView` so a short viewport clips them
/// instead of overflowing.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    required this.rowBuilder,
    this.rowHeight = defaultSkeletonItemHeight,
    this.padding = const EdgeInsets.fromLTRB(
      paddingSizeSmall,
      paddingSizeSmall,
      paddingSizeSmall,
      paddingSizeSmall,
    ),
  });

  final WidgetBuilder rowBuilder;
  final double rowHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = bonesForHeight(
          constraints.maxHeight - padding.vertical,
          itemHeight: rowHeight,
        );

        return ListView.builder(
          padding: padding,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          itemBuilder: (BuildContext context, int index) => rowBuilder(context),
        );
      },
    );
  }
}

/// Two text lines of different widths — a title and its supporting line.
class SkeletonLines extends StatelessWidget {
  const SkeletonLines({
    super.key,
    this.widths = const <double>[0.6, 0.4],
    this.spacing = paddingSizeXXSmall,
  });

  final List<double> widths;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 200;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int index = 0; index < widths.length; index++) ...<Widget>[
              if (index > 0) SizedBox(height: spacing),
              SkeletonBone(width: available * widths[index]),
            ],
          ],
        );
      },
    );
  }
}
