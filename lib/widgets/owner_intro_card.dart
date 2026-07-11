import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'reveal_on_scroll.dart';

/// Dropped into Home right where the embedded Services section used to sit
/// (see HomeScreen): a tappable "available for" list — restaurant owners,
/// hotel owners, company owners, branding clients, illustration clients,
/// individuals after a private workshop, aspiring designers, and content
/// creators — that jump straight to the matching category on the
/// standalone Services tab.
///
/// This sits on a soft full-bleed background band (not a bordered/rounded
/// card) — enough to set it apart from the Services/Illustration Art/Most
/// Requested rows above and below. Unlike those, this section deliberately
/// breaks from the Instagram-story circle look: each audience is a plain
/// vertical list row (rounded-square icon chip + name), grouped into 3
/// columns of 3 on desktop.
class OwnerIntroCard extends StatelessWidget {
  final bool isMobile;
  // No longer rendered here (the "View full profile" button was removed),
  // but kept on the constructor so call sites (HomeScreen/MainShell) don't
  // need to change — MainShell still passes its Portfolio-tab jump here.
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
      _AudienceSpec(Icons.lightbulb_rounded, context.strings.creativityLabel, () => onAudienceTap(1)),
      _AudienceSpec(Icons.school_rounded, context.strings.privateWorkshopIndividualsLabel, () => onAudienceTap(2)),
      _AudienceSpec(Icons.support_agent_rounded, context.strings.aspiringDesignersLabel, () => onAudienceTap(0)),
      _AudienceSpec(Icons.video_camera_front_rounded, context.strings.contentCreatorsLabel, () => onAudienceTap(1)),
    ];

    // Mobile stays a plain single-column list (full width rows). Desktop
    // now splits into 3 columns of 3 (9 audiences total) instead of 2
    // columns of 4 — first third filling the left column top-to-bottom,
    // next third the middle, last third the right — with a clear gap
    // between each column group (not spaceBetween/edge-to-edge) and
    // capped + centered so it stays tidy on very wide screens.
    const desktopItemWidth = 380.0;
    const desktopColumnGap = 36.0;
    const desktopColumns = 3;
    final desktopPerColumn = (audiences.length / desktopColumns).ceil();
    final desktopColumnsList = [
      for (var c = 0; c < desktopColumns; c++)
        audiences.sublist(
          c * desktopPerColumn,
          ((c + 1) * desktopPerColumn).clamp(0, audiences.length),
        ),
    ];

    Widget desktopColumn(List<_AudienceSpec> items) => Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i != 0) const SizedBox(height: 14),
              _AudienceListItem(
                icon: items[i].icon,
                label: items[i].label,
                onTap: items[i].onTap,
              ),
            ],
          ],
        );

    final audienceCircles = isMobile
        ? Column(
            children: [
              for (var i = 0; i < audiences.length; i++) ...[
                if (i != 0) const SizedBox(height: 12),
                _AudienceListItem(
                  icon: audiences[i].icon,
                  label: audiences[i].label,
                  onTap: audiences[i].onTap,
                ),
              ],
            ],
          )
        : Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < desktopColumnsList.length; c++) ...[
                    if (c != 0) const SizedBox(width: desktopColumnGap),
                    SizedBox(width: desktopItemWidth, child: desktopColumn(desktopColumnsList[c])),
                  ],
                ],
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? colors.violetPop.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border(0.12)),
          ),
          child: Row(
            children: [
              // Icon chip — rounded square with the same violet-gradient
              // border treatment as the circle rings elsewhere.
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: colors.violetGradient,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: colors.surface,
                  ),
                  child: Center(
                    child: Icon(widget.icon, size: 25, color: colors.violetPop),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppFonts.label(
                    size: 17,
                    weight: FontWeight.w600,
                    color: colors.cream,
                    letterSpacing: 0.3,
                    text: widget.label,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: colors.cream.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
