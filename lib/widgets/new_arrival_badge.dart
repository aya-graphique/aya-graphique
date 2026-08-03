import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Badge for freshly added products. Replaces the plain solid-color pill
/// every other badge on the card uses — this one gets its own identity
/// (moving gradient sheen in the brand's violet/orchid tones + a small
/// twinkling sparkle) so "just landed" products actually catch the eye
/// while scrolling the grid, instead of blending in as just another
/// colored label.
class NewArrivalBadge extends StatefulWidget {
  final String text;

  const NewArrivalBadge({super.key, required this.text});

  @override
  State<NewArrivalBadge> createState() => _NewArrivalBadgeState();
}

class _NewArrivalBadgeState extends State<NewArrivalBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Brand violet/orchid, same family as the rest of the storefront's
    // gradients — keeps this badge clearly "on brand" while the moving
    // sheen still gives it its own presentational identity. Uses violetMid
    // (rather than the much darker violetDeep) as the base so the sweep
    // stays light and airy instead of reading as a heavy block of color.
    final violetMid = context.colors.violetMid;
    final violetPop = context.colors.violetPop;
    final orchid = context.colors.orchid;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Sheen sweeps left-to-right and loops, like light catching foil.
        final sweep = (t * 2.6) - 0.8;
        // Sparkle twinkles on its own faster, offset cycle.
        final sparkleT = (t * 2) % 1.0;
        final sparkleOpacity =
            (0.35 + 0.65 * (0.5 - (sparkleT - 0.5).abs()) * 2).clamp(0.0, 1.0);

        return Container(
          // A touch larger than the other corner pills so it reads as
          // the standout badge among them.
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              begin: Alignment(sweep - 0.6, 0),
              end: Alignment(sweep + 0.6, 0),
              colors: [violetMid, violetPop, orchid, violetPop, violetMid],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: orchid.withOpacity(0.28),
                blurRadius: 7,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: sparkleOpacity,
                child: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 5),
              Text(
                widget.text.toUpperCase(),
                style: AppFonts.label(
                  text: widget.text,
                  size: 11,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }
}
