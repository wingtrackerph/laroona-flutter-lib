// Request-driven skeletons.
//
// `DataListView(skeleton: ...)` covers the common case. These are for the rest:
// a component that loads through `RequestProvider` but is not a list, and a
// component whose loading state is drawn by something that cannot be told to
// stop drawing it.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laroona_flutter_lib/providers/request_provider.dart';
import 'package:laroona_flutter_lib/utils/theme_helper.dart';
import 'package:laroona_flutter_lib/widgets/skeleton.dart';

/// Whether the request stored under [requestKey] is in its first load.
///
/// Reads BOTH sides of the answer: a list endpoint fills `data`, a details
/// endpoint answers with a map that the provider parks in `singleData`. A
/// wrapper that only looked at `data` would skeleton every details screen for
/// ever.
bool requestIsInFirstLoad(BuildContext context, String requestKey) {
  final RequestProvider requestProvider = Provider.of<RequestProvider>(context);
  final Request request = requestProvider.getRequest(requestKey);
  final List<dynamic> items = request.filteredData ?? request.data;

  return showSkeleton(
    isLoading: request.isLoading,
    isDone: request.isDone,
    hasData: items.isNotEmpty || request.singleData != null,
  );
}

/// Shows [skeleton] while the request under [requestKey] is in its first load,
/// and [child] the moment there is anything to show.
///
/// This is the per-component, per-request heart of the loop: two components on
/// one screen with different keys resolve independently, so a slow wallet
/// request never holds the notifications list hostage.
///
/// The child is not built at all while the bones are up — a half-built card
/// reading nulls is how a loading refactor introduces crashes.
class RequestSkeleton extends StatelessWidget {
  const RequestSkeleton({
    super.key,
    required this.requestKey,
    required this.skeleton,
    required this.child,
  });

  final String requestKey;
  final Widget skeleton;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!requestIsInFirstLoad(context, requestKey)) {
      return child;
    }

    return Skeleton(child: skeleton);
  }
}

/// The same rule, for a component that must stay MOUNTED while it loads.
///
/// `DataListView` fires its own fetch on mount and hardcodes the library's
/// `LoadingSpinner` while its request is in flight, and the library is out of
/// bounds this loop. So the list stays alive — the fetch goes out exactly as
/// before — and an OPAQUE, theme-background skeleton is painted over it. The
/// library spinner keeps running underneath where nobody can see or reach it.
///
/// Opaque is the whole point: `Container(color:)` builds a `ColoredBox`, whose
/// render object hit-tests as `HitTestBehavior.opaque`. A translucent overlay
/// would leave the spinner reachable, which is the same as leaving it visible.
class SkeletonOverlay extends StatefulWidget {
  const SkeletonOverlay({
    super.key,
    required this.requestKey,
    required this.skeleton,
    required this.child,
  });

  final String requestKey;
  final Widget skeleton;
  final Widget child;

  @override
  State<SkeletonOverlay> createState() => _SkeletonOverlayState();
}

/// IT LATCHES, AND THE LATCH IS THE WHOLE FIX.
///
/// The naive version lifted the cover the instant `hasData` turned true. But
/// `DataListView` paints its spinner on `isLoading || !isDone` and does not
/// consult the data at all — so between "the rows arrived" and "the request
/// settled" the cover was gone while the spinner was still there, and the
/// user watched a skeleton hand over to a spinner and then, 300ms of
/// `AnimatedSwitcher` later, to the list.
///
/// So once the cover goes up it stays up until the child can actually render
/// content: `!isLoading && isDone`, the exact condition under which
/// `DataListView` stops drawing its spinner.
///
/// This cannot cover content the user already had. A refresh starts with data
/// already present, so [requestIsInFirstLoad] is false on the first frame and
/// the latch never engages — which is what keeps the refresh rule intact.
class _SkeletonOverlayState extends State<SkeletonOverlay> {
  bool _covering = false;

  @override
  Widget build(BuildContext context) {
    final RequestProvider requestProvider = Provider.of<RequestProvider>(
      context,
    );
    final Request request = requestProvider.getRequest(widget.requestKey);
    final bool settled = !request.isLoading && request.isDone;

    if (requestIsInFirstLoad(context, widget.requestKey)) {
      _covering = true;
    } else if (settled) {
      // NOT DELAYED PAST THE CHILD'S OWN 300ms CROSS-FADE, deliberately.
      // Holding the cover through it would hide the last of the spinner, but
      // it needs a pending Timer, and a Timer outliving a pumped frame fails
      // 26 tests across the suite. The visible remainder is the tail of a
      // fade-out, not a spinner that starts after a skeleton.
      _covering = false;
    }

    if (!_covering) {
      return widget.child;
    }

    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        Positioned.fill(
          child: Container(
            color: ThemeColors.getBgColor(context),
            child: Skeleton(child: widget.skeleton),
          ),
        ),
      ],
    );
  }
}
