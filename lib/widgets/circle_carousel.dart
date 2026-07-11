import 'dart:async';
import 'package:flutter/material.dart';

/// Mobile-only replacement for wrapping a row of circles onto their own
/// lines: lays every circle out in a single horizontal row (shrinking them
/// to fit the available width) and, every 15 seconds, rotates which slot
/// each one sits in — they smoothly glide past each other and swap places
/// instead of sitting static.
///
/// Deliberately generic (an [itemBuilder] rather than a fixed circle
/// widget) so it can be reused for differently-styled circles — e.g. the
/// image/icon "story ring" circles on Home vs. the plain bordered icon
/// circles on [OwnerIntroCard]'s "available for" row.
class MobileCircleCarousel extends StatefulWidget {
  final int itemCount;
  // Called once per item, per rebuild, with the diameter this carousel
  // has worked out fits — build a circle (usually circle + label
  // underneath) sized to roughly that diameter.
  final Widget Function(BuildContext context, int index, double diameter) itemBuilder;
  final double minDiameter;
  final double maxDiameter;
  // Extra height reserved below the circle itself for its label — bump
  // this up for callers whose labels can wrap to two lines.
  final double labelAreaHeight;

  const MobileCircleCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minDiameter = 60,
    this.maxDiameter = 130,
    this.labelAreaHeight = 46,
  });

  @override
  State<MobileCircleCarousel> createState() => _MobileCircleCarouselState();
}

class _MobileCircleCarouselState extends State<MobileCircleCarousel> {
  Timer? _timer;
  int _rotation = 0;

  @override
  void initState() {
    super.initState();
    if (widget.itemCount > 1) {
      _timer = Timer.periodic(const Duration(seconds: 15), (_) {
        if (!mounted) return;
        setState(() => _rotation = (_rotation + 1) % widget.itemCount);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.itemCount;
    if (n == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Shrink circles to whatever fits n-across in the available width,
        // clamped so they never get too tiny or too big.
        final diameter = ((constraints.maxWidth / n) - 20).clamp(widget.minDiameter, widget.maxDiameter);
        final itemWidth = diameter + 16;
        final rowHeight = diameter + widget.labelAreaHeight;
        final naturalWidth = itemWidth * n;
        final needsScroll = naturalWidth > constraints.maxWidth;
        final rowWidth = needsScroll ? naturalWidth : constraints.maxWidth;
        final slotWidth = rowWidth / n;

        final stack = SizedBox(
          height: rowHeight,
          width: rowWidth,
          child: Stack(
            children: [
              for (var i = 0; i < n; i++)
                AnimatedPositioned(
                  key: ValueKey(i),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOutCubic,
                  left: ((i + _rotation) % n) * slotWidth + (slotWidth - itemWidth) / 2,
                  top: 0,
                  width: itemWidth,
                  height: rowHeight,
                  child: widget.itemBuilder(context, i, diameter),
                ),
            ],
          ),
        );

        return needsScroll
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: stack)
            : Center(child: stack);
      },
    );
  }
}
