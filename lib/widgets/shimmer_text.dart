import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A headline that continuously catches the light: the text color pulses
/// gently between the base cream and a soft lilac, then back. Pure
/// AnimationController + Text — no ShaderMask.
///
/// This used to be built with ShaderMask (a moving gradient sweep clipped
/// to the text shape). That looked nicer in theory, but ShaderMask proved
/// unreliable in this app's actual runtime: it silently painted nothing
/// at all in some places (the navbar wordmark) and continued to fail
/// here even after the gradient math itself was fixed and confirmed
/// correct in isolation. Rather than keep chasing shader edge cases, this
/// swaps to plain Text with an animated color — every other heading on
/// this page already renders reliably that exact way, so this guarantees
/// the headline actually shows up, at the cost of a slightly simpler
/// animation (a color pulse instead of a moving highlight sweep).
class ShimmerHeadline extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const ShimmerHeadline({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.left,
  });

  @override
  State<ShimmerHeadline> createState() => _ShimmerHeadlineState();
}

class _ShimmerHeadlineState extends State<ShimmerHeadline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.cream;
    // In light mode `orchidSoft` is a bright lavender that reads faint
    // against the white background — swap to a darker mid-violet there so
    // the shimmer stays legible instead of washing the headline out.
    final highlight = context.themeController.isDark
        ? context.colors.orchidSoft
        : context.colors.violetMid;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(base, highlight, _controller.value) ?? base;
        return Text(
          widget.text,
          textAlign: widget.textAlign,
          style: widget.style.copyWith(color: color),
        );
      },
    );
  }
}
