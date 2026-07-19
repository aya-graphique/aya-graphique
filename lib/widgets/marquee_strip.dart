import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// An infinitely-scrolling horizontal strip of words, separated by a small
/// sparkle glyph — the same accent motif used on the eyebrow pills
/// elsewhere on Home — on a soft gradient backdrop with hairline gradient
/// edges top and bottom, and the text itself gently fading out at both
/// ends instead of hard-clipping. Purely decorative motion used as a
/// section divider — the kind of continuous marquee a print-inspired
/// brand site leans on.
class MarqueeStrip extends StatefulWidget {
  final List<String> words;
  final double height;
  final double pixelsPerSecond;

  const MarqueeStrip({
    super.key,
    required this.words,
    this.height = 48,
    this.pixelsPerSecond = 34,
  });

  @override
  State<MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<MarqueeStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _rowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSpeed());
  }

  @override
  void didUpdateWidget(covariant MarqueeStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.words != widget.words ||
        oldWidget.pixelsPerSecond != widget.pixelsPerSecond) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncSpeed());
    }
  }

  void _syncSpeed() {
    if (!mounted) return;
    final box = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || box.size.width <= 0) return;
    final seconds = box.size.width / widget.pixelsPerSecond;
    final newDuration = Duration(milliseconds: (seconds * 1000).round());
    if (newDuration == _controller.duration) return;
    _controller.duration = newDuration;
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget buildRow({Key? key}) {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.words.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.words[i],
                  style: AppFonts.display(
                    size: 18,
                    weight: FontWeight.w600,
                    color: colors.cream,
                    letterSpacing: 0.3,
                    text: widget.words[i],
                  ),
                ),
                const SizedBox(width: 14),
                Icon(Icons.auto_awesome_rounded, size: 13, color: colors.orchid),
              ],
            ),
          );
        }),
      );
    }

    final row = buildRow(key: _rowKey);
    final rowCopy = buildRow();

    // Same faded hairline treatment used under the eyebrow pills elsewhere
    // on Home, rather than a flat solid-colour rule.
    final hairline = Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            colors.violetPop.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [colors.surface, colors.surfaceRaised, colors.surface],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.violetPop.withOpacity(0.1),
            blurRadius: 26,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: [
          hairline,
          Expanded(
            child: ClipRect(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.08, 0.92, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final isRtl = Directionality.of(context) == TextDirection.rtl;
                    return OverflowBox(
                      maxWidth: double.infinity,
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionalTranslation(
                        // Flip the scroll direction in RTL so the strip
                        // visually drifts toward the reading start (right)
                        // instead of always crawling left like it does in
                        // English.
                        translation: Offset((isRtl ? 1 : -1) * _controller.value * 0.5, 0),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [row, rowCopy]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          hairline,
        ],
      ),
    );
  }
}
