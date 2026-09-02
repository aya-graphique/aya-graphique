import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final TextAlign align;
  final bool boostArabicSize;
  final double titleSize;
  final double? eyebrowSize;
  final IconData? eyebrowIcon;

  // Every SectionHeading's title shrinks to this same size on phones,
  // regardless of the [titleSize] a screen passes in for desktop — so
  // "المنتجات" on the shop, "اعمالي" on My Works, "السلة" on the cart,
  // etc. all read the same, consistent size on mobile instead of each
  // screen drifting to whatever size it happened to be given. Screens
  // that already asked for something smaller than this on mobile (e.g.
  // a compact inline heading) keep their smaller size — this only caps
  // headings down, never enlarges one that was already asked to be tiny.
  static const double _mobileTitleCap = 18;

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.align = TextAlign.start,
    this.boostArabicSize = true,
    this.titleSize = 30,
    this.eyebrowSize,
    this.eyebrowIcon,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxis = align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final effectiveTitleSize = isMobile ? (titleSize < _mobileTitleCap ? titleSize : _mobileTitleCap) : titleSize;
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            eyebrowIcon != null
                ? Icon(eyebrowIcon, size: (eyebrowSize ?? 12) + 3, color: context.colors.orchid)
                : Container(
                    width: 28,
                    height: 2,
                    color: context.colors.orchid,
                  ),
            const SizedBox(width: 10),
            Text(eyebrow,
                style: AppFonts.label(text: eyebrow, 
                  color: context.colors.orchid,
                  boostArabicSize: boostArabicSize,
                  size: eyebrowSize ?? 12,
                )),
          ],
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        Text(title,
          textAlign: align,
          style: AppFonts.display(text: title, color: context.colors.cream, size: effectiveTitleSize, height: 1.08, boostArabicSize: boostArabicSize),
        ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(
              begin: 0.15,
              end: 0,
              curve: Curves.easeOutCubic,
            ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: 560,
            child: Text(subtitle!,
              textAlign: align,
              style: AppFonts.body(text: subtitle!, color: context.colors.creamDim, size: 16.5, boostArabicSize: boostArabicSize),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ],
    );
  }
}
