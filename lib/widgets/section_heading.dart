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

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.align = TextAlign.start,
    this.boostArabicSize = true,
    this.titleSize = 40,
    this.eyebrowSize,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxis = align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 2,
              color: context.colors.orchid,
            ),
            const SizedBox(width: 10),
            Text(eyebrow,
                style: AppFonts.label(
                  color: context.colors.orchid,
                  boostArabicSize: boostArabicSize,
                  size: eyebrowSize ?? 13,
                )),
          ],
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: align,
          style: AppFonts.display(color: context.colors.cream, size: titleSize, height: 1.08, boostArabicSize: boostArabicSize),
        ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(
              begin: 0.15,
              end: 0,
              curve: Curves.easeOutCubic,
            ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: 560,
            child: Text(
              subtitle!,
              textAlign: align,
              style: AppFonts.body(color: context.colors.creamDim, size: 16.5, boostArabicSize: boostArabicSize),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ],
    );
  }
}
