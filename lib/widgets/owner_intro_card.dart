import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'reveal_on_scroll.dart';

/// Dropped into Home right where the embedded Services section used to sit
/// (see HomeScreen): tappable "available for" circles — restaurant owners,
/// hotel owners, company owners, branding clients, illustration clients,
/// individuals after a private workshop, and aspiring designers — that jump
/// straight to the matching category on the standalone Services tab, plus a
/// button that jumps to the standalone Portfolio ("Who am I") tab. A thin
/// divider separates the circles from the "available for" eyebrow pill
/// above them.
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
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: [
            _AudienceCircle(
              icon: Icons.restaurant_rounded,
              label: context.strings.restaurantOwnersLabel,
              floatDelayIndex: 0,
              onTap: () => onAudienceTap(1),
            ),
            _AudienceCircle(
              icon: Icons.hotel_rounded,
              label: context.strings.hotelOwnersLabel,
              floatDelayIndex: 1,
              onTap: () => onAudienceTap(1),
            ),
            _AudienceCircle(
              icon: Icons.business_center_rounded,
              label: context.strings.companyOwnersLabel,
              floatDelayIndex: 2,
              onTap: () => onAudienceTap(1),
            ),
            _AudienceCircle(
              icon: Icons.branding_watermark_rounded,
              label: context.strings.brandingLabel,
              floatDelayIndex: 3,
              onTap: () => onAudienceTap(1),
            ),
            _AudienceCircle(
              icon: Icons.palette_rounded,
              label: context.strings.illustrationClientsLabel,
              floatDelayIndex: 4,
              onTap: () => onAudienceTap(1),
            ),
            _AudienceCircle(
              icon: Icons.school_rounded,
              label: context.strings.privateWorkshopIndividualsLabel,
              floatDelayIndex: 5,
              onTap: () => onAudienceTap(2),
            ),
            _AudienceCircle(
              icon: Icons.support_agent_rounded,
              label: context.strings.aspiringDesignersLabel,
              floatDelayIndex: 6,
              onTap: () => onAudienceTap(0),
            ),
          ],
        ),
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

    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: colors.surfaceRaised.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border(0.08)),
      ),
      child: content,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: RevealOnScroll(child: card),
    );
  }
}

/// One tappable "available for" circle inside [OwnerIntroCard] — a round
/// icon badge with its label underneath. Tapping jumps straight to the
/// matching category on the Services tab.
class _AudienceCircle extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int floatDelayIndex;

  const _AudienceCircle({
    required this.icon,
    required this.label,
    required this.onTap,
    this.floatDelayIndex = 0,
  });

  @override
  State<_AudienceCircle> createState() => _AudienceCircleState();
}

class _AudienceCircleState extends State<_AudienceCircle> {
  bool _hovered = false;

  static const double _circleSize = 132;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: 148,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _circleSize,
                height: _circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hovered ? colors.violetPop.withOpacity(0.24) : colors.violetPop.withOpacity(0.1),
                  border: Border.all(
                    color: _hovered ? colors.violetPop : colors.violetPop.withOpacity(0.55),
                    width: _hovered ? 2.4 : 2,
                  ),
                ),
                child: Icon(widget.icon, size: 40, color: colors.violetPop),
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
              const SizedBox(height: 12),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.body(
                  color: colors.cream,
                  size: 15,
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
