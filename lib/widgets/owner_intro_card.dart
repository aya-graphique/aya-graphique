import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'reveal_on_scroll.dart';

/// Dropped into Home right where the embedded Services section used to sit
/// (see HomeScreen): 3 tappable "available for" rows — restaurant owners,
/// hotel owners, individuals after a private workshop — that jump straight
/// to the matching category on the standalone Services tab, plus a button
/// down to the full "Who am I" profile further below this same page.
class OwnerIntroCard extends StatelessWidget {
  final bool isMobile;
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
    final crossAxis = isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;

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
        const SizedBox(height: 18),
        _AudienceRow(
          icon: Icons.restaurant_rounded,
          label: context.strings.restaurantOwnersLabel,
          onTap: () => onAudienceTap(1),
        ),
        const SizedBox(height: 8),
        _AudienceRow(
          icon: Icons.hotel_rounded,
          label: context.strings.hotelOwnersLabel,
          onTap: () => onAudienceTap(1),
        ),
        const SizedBox(height: 8),
        _AudienceRow(
          icon: Icons.school_rounded,
          label: context.strings.privateWorkshopIndividualsLabel,
          onTap: () => onAudienceTap(2),
        ),
        const SizedBox(height: 22),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.strings.viewFullProfile,
                  style: AppFonts.label(size: 12.5, color: Colors.white, letterSpacing: 0.6)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_downward_rounded, size: 15, color: Colors.white),
              ],
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
        border: Border.all(color: colors.cream.withOpacity(0.08)),
      ),
      child: content,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: RevealOnScroll(child: card),
    );
  }
}

/// One tappable "available for" row inside [OwnerIntroCard] — an icon, a
/// label, and a trailing chevron in the reading direction. Tapping jumps
/// straight to the matching category on the Services tab.
class _AudienceRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AudienceRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_AudienceRow> createState() => _AudienceRowState();
}

class _AudienceRowState extends State<_AudienceRow> {
  bool _hovered = false;

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? colors.violetPop.withOpacity(0.14) : colors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.cream.withOpacity(_hovered ? 0.16 : 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.violetPop.withOpacity(0.16),
                ),
                child: Icon(widget.icon, size: 15, color: colors.orchid),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppFonts.body(
                    color: colors.cream,
                    size: 13.5,
                    weight: FontWeight.w600,
                    text: widget.label,
                    boostArabicSize: false,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: colors.creamDim),
            ],
          ),
        ),
      ),
    );
  }
}
