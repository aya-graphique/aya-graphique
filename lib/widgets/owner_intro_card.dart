import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'circle_carousel.dart';
import 'reveal_on_scroll.dart';

/// Dropped into Home right where the embedded Services section used to sit
/// (see HomeScreen): tappable "available for" circles — restaurant owners,
/// hotel owners, company owners, branding clients, illustration clients,
/// individuals after a private workshop, and aspiring designers — that jump
/// straight to the matching category on the standalone Services tab, plus a
/// button that jumps to the standalone Portfolio ("Who am I") tab.
///
/// This sits directly on the page background — no card/box wrapping the
/// "available for" eyebrow + circles + button, just the reveal-on-scroll
/// animation and the page's own horizontal padding. The circles themselves
/// use the same Instagram-story gradient-ring look as every other circle
/// row on the page (Services, Illustration Art, Most Requested).
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

    final audienceCircles = isMobile
        ? MobileCircleCarousel(
            itemCount: audiences.length,
            // Labels here can run to two lines ("Restaurant owners"), so
            // this row gets a taller label area than the plain one-line
            // circles elsewhere.
            labelAreaHeight: 62,
            itemBuilder: (context, i, diameter) => _AudienceCircle(
              icon: audiences[i].icon,
              label: audiences[i].label,
              diameter: diameter,
              iconSize: diameter * 0.36,
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
                _AudienceCircle(
                  icon: audiences[i].icon,
                  label: audiences[i].label,
                  floatDelayIndex: i,
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
        audienceCircles,
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

/// A plain (icon, label, tap target) bundle for an audience circle — kept
/// separate from the built widget so the layout picked at build time
/// (desktop Wrap vs. mobile carousel) can each size the circles however
/// suits that layout.
class _AudienceSpec {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AudienceSpec(this.icon, this.label, this.onTap);
}

/// One tappable "available for" circle inside [OwnerIntroCard] — same
/// Instagram-story styling as the rest of the app's circle rows (Services,
/// Illustration Art, Most Requested — see [_EyebrowCirclesSection] /
/// [_MostRequestedCircles] in home_screen.dart, and their shared
/// `_CategoryCircle`): a gradient ring always framing the icon, a gentle
/// float loop, and a slight shrink on hover/tap instead of a glow. Tapping
/// jumps straight to the matching category on the Services tab.
class _AudienceCircle extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  // Desktop keeps its original fixed circle size and label size below —
  // the mobile carousel passes its own smaller, width-fitted values.
  final double diameter;
  final double labelSize;
  final double iconSize;
  // Staggers the float animation per-circle on desktop (see
  // `_CategoryCircle.floatDelayIndex`) so a whole row doesn't bob in
  // lockstep. Mobile leaves this at 0 since the carousel already staggers
  // circles by swapping their positions.
  final int floatDelayIndex;

  const _AudienceCircle({
    required this.icon,
    required this.label,
    required this.onTap,
    this.diameter = 132,
    this.labelSize = 15,
    this.iconSize = 44,
    this.floatDelayIndex = 0,
  });

  @override
  State<_AudienceCircle> createState() => _AudienceCircleState();
}

class _AudienceCircleState extends State<_AudienceCircle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final diameter = widget.diameter;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: diameter + 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
                scale: _hovered ? 0.92 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: diameter,
                  height: diameter,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: colors.violetGradient,
                    boxShadow: [
                      BoxShadow(
                        color: colors.violetPop.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface,
                      border: Border.all(color: colors.bgDeep, width: 2),
                    ),
                    child: Center(
                      child: Icon(widget.icon, size: widget.iconSize, color: colors.violetPop),
                    ),
                  ),
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                    delay: Duration(milliseconds: 90 * widget.floatDelayIndex),
                  )
                  .moveY(
                    begin: 0,
                    end: -9,
                    duration: 1700.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.label(
                  size: widget.labelSize,
                  weight: FontWeight.w600,
                  color: colors.cream,
                  letterSpacing: 0.6,
                  text: widget.label,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
