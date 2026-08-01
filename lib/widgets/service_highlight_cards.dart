import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Plain data for one highlight card — filled in by the caller (e.g.
/// HomeScreen's services row, built straight from kServiceCategories so
/// the copy always stays in sync with the Services tab).
class ServiceHighlightData {
  // Null/empty until the owner uploads a photo for this category (same
  // source the old circles row used) — falls back to a plain icon tile.
  final String? imagePath;
  final bool isNetworkImage;
  final IconData? badgeIcon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const ServiceHighlightData({
    required this.title,
    required this.description,
    required this.onTap,
    this.imagePath,
    this.badgeIcon,
    this.isNetworkImage = true,
  });
}

/// One image-topped highlight card, styled after the reference design
/// (rounded photo on top, small circular badge in the corner, centered
/// title + description underneath, whole card tappable).
///
/// Font sizes are pulled directly from the same tokens already used by
/// `_CategoryCard` in graphical_services_screen.dart, so this stays
/// visually consistent with the rest of the app:
///   - title  -> AppFonts.display, size 20 (mobile) / 25 (desktop), w700
///   - body   -> AppFonts.body, size 13.5, height 1.6
class ServiceHighlightCard extends StatelessWidget {
  final ServiceHighlightData data;
  final bool isMobile;

  const ServiceHighlightCard({
    super.key,
    required this.data,
    required this.isMobile,
  });

  Widget _fallback(AppColors colors) => Container(
        color: colors.surface,
        alignment: Alignment.center,
        child: Icon(
          data.badgeIcon ?? Icons.auto_awesome_rounded,
          color: colors.creamDim,
          size: 40,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final noImage = data.imagePath == null || data.imagePath!.isEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: data.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surfaceRaised.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.border(0.1)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1.05,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (noImage)
                          _fallback(colors)
                        else if (data.isNetworkImage)
                          Image.network(
                            data.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => _fallback(colors),
                          )
                        else
                          Image.asset(
                            data.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => _fallback(colors),
                          ),
                        if (data.badgeIcon != null)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: Icon(data.badgeIcon, size: 14, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                child: Column(
                  children: [
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: AppFonts.display(
                        color: colors.cream,
                        size: isMobile ? 20 : 25,
                        weight: FontWeight.w700,
                        text: data.title,
                        boostArabicSize: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: AppFonts.body(
                        color: colors.creamDim,
                        size: 13.5,
                        height: 1.6,
                        text: data.description,
                        boostArabicSize: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays the highlight cards out as a row on wide screens and stacks them
/// on mobile.
class ServiceHighlightsRow extends StatelessWidget {
  final List<ServiceHighlightData> cards;
  final bool isMobile;

  const ServiceHighlightsRow({
    super.key,
    required this.cards,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            ServiceHighlightCard(data: cards[i], isMobile: isMobile),
            if (i != cards.length - 1) const SizedBox(height: 20),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          Expanded(child: ServiceHighlightCard(data: cards[i], isMobile: isMobile)),
          if (i != cards.length - 1) const SizedBox(width: 24),
        ],
      ],
    );
  }
}
