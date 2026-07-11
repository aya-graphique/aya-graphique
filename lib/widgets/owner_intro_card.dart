import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'reveal_on_scroll.dart';

/// Dropped into Home right where the embedded Services section used to sit
/// (see HomeScreen): a tappable "available for" list — restaurant owners,
/// hotel owners, company owners, branding clients, illustration clients,
/// individuals after a private workshop, and aspiring designers — that jump
/// straight to the matching category on the standalone Services tab, plus a
/// button that jumps to the standalone Portfolio ("Who am I") tab.
///
/// This sits on a soft full-bleed background band (not a bordered/rounded
/// card) — enough to set it apart from the Services/Illustration Art/Most
/// Requested rows above and below. Unlike those, this section deliberately
/// breaks from the Instagram-story circle look: each audience is a plain
/// vertical list row (small rounded-square icon chip + name).
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

    // Mobile stays a plain single-column list (full width rows). Desktop
    // switches to a centered 2-column grid instead of one narrow column —
    // a single 420px-wide list looked lost in all the leftover space on a
    // wide screen.
    const desktopColumns = 2;
    const desktopMaxWidth = 720.0;
    const desktopGap = 16.0;
    final desktopItemWidth = (desktopMaxWidth - desktopGap * (desktopColumns - 1)) / desktopColumns;

    final audienceCircles = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : desktopMaxWidth),
      child: isMobile
          ? Column(
              children: [
                for (var i = 0; i < audiences.length; i++) ...[
                  if (i != 0) const SizedBox(height: 10),
                  _AudienceListItem(
                    icon: audiences[i].icon,
                    label: audiences[i].label,
                    onTap: audiences[i].onTap,
                  ),
                ],
              ],
            )
          : Wrap(
              alignment: WrapAlignment.center,
              spacing: desktopGap,
              runSpacing: 12,
              children: [
                for (var i = 0; i < audiences.length; i++)
                  SizedBox(
                    width: desktopItemWidth,
                    child: _AudienceListItem(
                      icon: audiences[i].icon,
                      label: audiences[i].label,
                      onTap: audiences[i].onTap,
                    ),
                  ),
              ],
            ),
    );

    final content = Column(
      crossAxisAlignment: crossAxis,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: colors.violetPop.withOpacity(0.14),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: colors.orchid.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 17, color: colors.orchid),
              const SizedBox(width: 10),
              Text(
                context.strings.availableForEyebrow,
                style: AppFonts.label(color: colors.orchid, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Divider — same treatment as the one under the Services/
        // Illustration Art/Most Requested eyebrow pills.
        Container(
          height: 1,
          width: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                colors.border(0.14),
                Colors.transparent,
              ],
            ),
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

    // Plain transparent padding — no background band. This used to sit on
    // its own soft-tinted band to stand apart from the sections above/
    // below, but that read as a stray light-purple rectangle rather than
    // blending with the rest of the page — a plain background matches the
    // page better than a differently-colored one does.
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 20 : 28,
      ),
      child: RevealOnScroll(child: content),
    );
  }
}

/// A plain (icon, label, tap target) bundle for an audience row — kept
/// separate from [_AudienceListItem] purely to build the `audiences` list
/// once above.
class _AudienceSpec {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AudienceSpec(this.icon, this.label, this.onTap);
}

/// One tappable "available for" row inside [OwnerIntroCard]: a small
/// rounded-square icon chip (violet gradient border, same family as the
/// gradient ring used elsewhere) followed by the audience name — stacked
/// into a plain vertical list instead of a circle row. Slides/dims
/// slightly on hover/tap; tapping jumps straight to the matching category
/// on the Services tab.
class _AudienceListItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AudienceListItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_AudienceListItem> createState() => _AudienceListItemState();
}

class _AudienceListItemState extends State<_AudienceListItem> {
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? colors.violetPop.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border(0.12)),
          ),
          child: Row(
            children: [
              // Icon chip — rounded square with the same violet-gradient
              // border treatment as the circle rings elsewhere.
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: colors.violetGradient,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: colors.surface,
                  ),
                  child: Center(
                    child: Icon(widget.icon, size: 20, color: colors.violetPop),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppFonts.label(
                    size: 14.5,
                    weight: FontWeight.w600,
                    color: colors.cream,
                    letterSpacing: 0.3,
                    text: widget.label,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                size: 20,
                color: colors.cream.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
