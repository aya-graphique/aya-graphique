import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'circle_carousel.dart';
import 'reveal_on_scroll.dart';

/// Dropped into Home right where the embedded Services section used to sit
/// (see HomeScreen): tappable "available for" tiles — restaurant owners,
/// hotel owners, company owners, branding clients, illustration clients,
/// individuals after a private workshop, and aspiring designers — that jump
/// straight to the matching category on the standalone Services tab, plus a
/// button that jumps to the standalone Portfolio ("Who am I") tab.
///
/// Unlike the previous version, this sits directly on the page background —
/// no card/box wrapping the "available for" eyebrow + tiles + button, just
/// the reveal-on-scroll animation and the page's own horizontal padding.
class OwnerIntroCard extends StatelessWidget {
  final bool isMobile;
  // Jumps to the standalone Portfolio/About tab — see
  // MainShell._goTo / HomeScreen.onViewProfileTap.
  final VoidCallback onViewProfile;
  // Jumps to the Services tab and focuses category [index] there — see
  // MainShell._openServiceCategory / kServiceCategories.
  final ValueChanged<int> onAudienceTap;

  const OwnerIntroCard({
    super.key,
    required this.isMobile,
    required this.onViewProfile,
    required this.onAudienceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const crossAxis = CrossAxisAlignment.center;

    final audiences = <_AudienceSpec>[
      _AudienceSpec(Icons.restaurant_rounded, context.strings.restaurantOwnersLabel, () => onAudienceTap(1)),
      _AudienceSpec(Icons.hotel_rounded, context.strings.hotelOwnersLabel, () => onAudienceTap(1)),
      _AudienceSpec(Icons.business_center_rounded, context.strings.companyOwnersLabel, () => onAudienceTap(1)),
      _AudienceSpec(Icons.branding_watermark_rounded, context.strings.brandingLabel, () => onAudienceTap(1)),
      _AudienceSpec(Icons.palette_rounded, context.strings.illustrationClientsLabel, () => onAudienceTap(1)),
      _AudienceSpec(Icons.school_rounded, context.strings.privateWorkshopIndividualsLabel, () => onAudienceTap(2)),
      _AudienceSpec(Icons.support_agent_rounded, context.strings.aspiringDesignersLabel, () => onAudienceTap(0)),
    ];

    final audienceTiles = isMobile
        ? MobileCircleCarousel(
            itemCount: audiences.length,
            // Labels here can run to two lines ("Restaurant owners"), so
            // this row gets a taller label area than the plain one-line
            // tiles elsewhere.
            labelAreaHeight: 62,
            itemBuilder: (context, i, diameter) => _AudienceTile(
              icon: audiences[i].icon,
              label: audiences[i].label,
              size: diameter,
              iconSize: diameter * 0.32,
              labelSize: (diameter * 0.12).clamp(10.0, 13.0),
              onTap: audiences[i].onTap,
            ),
          )
        : Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              for (var i = 0; i < audiences.length; i++)
                _AudienceTile(
                  icon: audiences[i].icon,
                  label: audiences[i].label,
                  onTap: audiences[i].onTap,
                ),
            ],
          );

    final content = Column(
      crossAxisAlignment: crossAxis,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: colors.violetPop.withOpacity(0.14),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: colors.orchid.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 13, color: colors.orchid),
              const SizedBox(width: 8),
              Text(
                context.strings.availableForEyebrow,
                style: AppFonts.label(color: colors.orchid, size: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        audienceTiles,
        const SizedBox(height: 26),
        GestureDetector(
          onTap: onViewProfile,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: colors.violetGradient,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: colors.violetPop.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              context.strings.viewFullProfile,
              style: AppFonts.label(size: 12.5, color: Colors.white, letterSpacing: 0.6)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );

    // No surrounding card/box anymore — the section sits straight on the
    // page background, just like everything else on Home. Keep the same
    // outer horizontal padding the card used to have so the row still
    // lines up with the rest of the page content.
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: isMobile ? 8 : 12),
      child: RevealOnScroll(child: content),
    );
  }
}

/// A plain (icon, label, tap target) bundle for an audience tile — kept
/// separate from the built widget so the layout picked at build time
/// (desktop Wrap vs. mobile carousel) can each size the tiles however
/// suits that layout.
class _AudienceSpec {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AudienceSpec(this.icon, this.label, this.onTap);
}

/// One tappable "available for" tile inside [OwnerIntroCard] — a rounded
/// square (squircle) badge with a violet→orchid gradient fill, glowing
/// softly, with its label underneath. Tapping jumps straight to the
/// matching category on the Services tab.
///
/// Replaces the previous plain outlined circle: same role in the layout
/// (built by [MobileCircleCarousel] on mobile, laid out in a [Wrap] on
/// desktop) but a different look — solid gradient card instead of a
/// bordered ring.
class _AudienceTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  // Desktop keeps its original fixed tile size and label size below — the
  // mobile carousel passes its own smaller, width-fitted values.
  final double size;
  final double labelSize;
  final double iconSize;

  const _AudienceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 120,
    this.labelSize = 15,
    this.iconSize = 38,
  });

  @override
  State<_AudienceTile> createState() => _AudienceTileState();
}

class _AudienceTileState extends State<_AudienceTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tileSize = widget.size;
    // Squircle-style corner radius: rounded enough to read as a "soft
    // square" rather than a chip, without turning into a full circle.
    final radius = tileSize * 0.32;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: tileSize + 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: tileSize,
                height: tileSize,
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(_hovered ? 1.04 : 1.0),
                transformAlignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _hovered
                        ? [colors.violetPop, colors.orchid]
                        : [colors.violetPop.withOpacity(0.85), colors.violetDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.violetPop.withOpacity(_hovered ? 0.45 : 0.28),
                      blurRadius: _hovered ? 20 : 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(widget.icon, size: widget.iconSize, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  color: colors.cream,
                  size: widget.labelSize,
                  weight: FontWeight.w600,
                  text: widget.label,
                  boostArabicSize: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
