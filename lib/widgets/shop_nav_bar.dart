import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../providers/cart_provider.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';

enum ShopPage { home, search, services, cart, about }

/// The same frosted glass pill nav from the Aya's Graphique brand system,
/// re-purposed for page navigation instead of scroll-to-section links, plus
/// a cart icon with a live item-count badge.
///
/// The bar itself stays a fixed, compact size (smaller on desktop, since
/// desktop has room to spare and a big bar there looks heavy). Each icon
/// inside it is what grows: the moment a pointer hovers (desktop) or
/// touches (mobile) a single icon, that icon pops up a bit larger with a
/// soft glow, then eases straight back to its normal size the instant the
/// pointer leaves or lifts — the rest of the bar never moves.
class ShopNavBar extends StatefulWidget {
  final ShopPage active;
  final ValueChanged<ShopPage> onTap;
  final bool isMobile;
  /// Fires every time the theme/language utility pill opens or closes,
  /// so the parent screen can make room for it (push its content down)
  /// instead of letting the pill float on top and cover it.
  final ValueChanged<bool>? onUtilityOpenChanged;

  const ShopNavBar({
    super.key,
    required this.active,
    required this.onTap,
    this.isMobile = false,
    this.onUtilityOpenChanged,
  });

  @override
  State<ShopNavBar> createState() => _ShopNavBarState();
}

class _ShopNavBarState extends State<ShopNavBar> {
  // Whether the small theme/language utility pill is currently shown.
  // Starts closed — it only appears once the shopper taps the "more"
  // button, and tapping it again tucks it back away, so the main bar
  // stays small and uncluttered by default.
  bool _utilityOpen = false;

  void _toggleUtility() {
    setState(() => _utilityOpen = !_utilityOpen);
    widget.onUtilityOpenChanged?.call(_utilityOpen);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final onTap = widget.onTap;
    final isMobile = widget.isMobile;
    final cartCount = context.watch<CartProvider>().itemCount;
    final isDark = context.watch<ThemeController>().isDark;
    final isArabic = context.watch<LanguageController>().isArabic;
    final strings = context.strings;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
              // Logo/wordmark — just takes the shopper home. The EN/AR
              // switch lives further down this row; it only ever touches
              // the storefront (LanguageController + FontController) — the
              // admin dashboard never reads either one, so it always stays
              // English regardless of what a shopper picks here.
              GestureDetector(
                onTap: () => onTap(ShopPage.home),
                // Plain, solid-colored text on purpose — no ShaderMask.
                // ShaderMask sits inside the same subtree as the
                // BackdropFilter blur above it, and on Flutter Web that
                // combination can silently fail to paint the masked
                // child at all (it isn't a color/contrast issue — the
                // gradient version never painted anything here). A flat
                // color has no such dependency and always paints, and
                // context.colors.cream already adapts correctly between
                // the light and dark themes.
                child: Text(
                  "Aya's",
                  style: AppFonts.display(
                    size: isMobile ? 20 : 17,
                    weight: FontWeight.w800,
                    color: context.colors.cream,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              if (!isMobile) ...[
                _NavIconLabel(
                  icon: Icons.storefront_rounded,
                  label: strings.navShop,
                  active: active == ShopPage.home,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.home),
                ),
                _NavIconLabel(
                  icon: Icons.search_rounded,
                  label: strings.navSearch,
                  active: active == ShopPage.search,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.search),
                ),
                _NavIconLabel(
                  icon: Icons.design_services_rounded,
                  label: strings.navServices,
                  active: active == ShopPage.services,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.services),
                ),
                _NavIconLabel(
                  icon: Icons.person_outline_rounded,
                  label: strings.navAbout,
                  active: active == ShopPage.about,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.about),
                ),
              ],
              _NavIconLabel(
                icon: Icons.shopping_bag_rounded,
                label: strings.navCart,
                stacked: isMobile,
                active: active == ShopPage.cart,
                isMobile: isMobile,
                badge: cartCount > 0 ? cartCount : null,
                onTap: () => onTap(ShopPage.cart),
              ),
              if (isMobile) ...[
                _NavIconLabel(
                  icon: Icons.search_rounded,
                  label: strings.navSearch,
                  stacked: true,
                  active: active == ShopPage.search,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.search),
                ),
                _NavIconLabel(
                  icon: Icons.design_services_rounded,
                  label: strings.navServices,
                  stacked: true,
                  active: active == ShopPage.services,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.services),
                ),
                _NavIconLabel(
                  icon: Icons.person_outline_rounded,
                  label: strings.navAbout,
                  stacked: true,
                  active: active == ShopPage.about,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.about),
                ),
              ],
      ],
    );

    final mainPill = _GlassPill(
      isMobile: isMobile,
      child: isMobile
          ? FittedBox(fit: BoxFit.scaleDown, child: row)
          : row,
    );

    // "More" toggle now lives as its own free-floating circle right next
    // to the main pill instead of being squeezed inside it as the last
    // item. Taking it out of the pill gives every page icon a bit more
    // breathing room, and the circle can never get clipped by the pill's
    // own rounded end cap since it isn't inside that shape anymore.
    final moreButton = _MoreToggleButton(open: _utilityOpen, onTap: _toggleUtility);

    // Theme (light/dark) and language (EN/AR) toggles live in their own
    // small pill, tucked away behind the "more" button above instead of
    // always taking up space — they don't navigate anywhere, so they
    // don't need to be on-screen permanently the way Shop/Search/etc do.
    final utilityRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavIconLabel(
          icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          active: false,
          isMobile: isMobile,
          onTap: () => context.themeController.toggleTheme(),
        ),
        _LanguageToggle(isArabic: isArabic, isMobile: isMobile),
      ],
    );

    // AnimatedSize + AnimatedOpacity gives the pill a soft grow/shrink and
    // fade in/out as it's toggled, instead of just popping in and out.
    final utilityPill = ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        heightFactor: _utilityOpen ? 1.0 : 0.0,
        widthFactor: isMobile ? 1.0 : (_utilityOpen ? 1.0 : 0.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _utilityOpen ? 1.0 : 0.0,
          child: _GlassPill(isMobile: isMobile, child: utilityRow),
        ),
      ),
    );

    // Desktop has spare horizontal room, so the two pills sit
    // side-by-side. Mobile doesn't — cramming both pills into one row
    // was exactly what made the fit feel wrong (either pill got
    // squeezed or the row overflowed). Stacking them instead only
    // costs a little vertical space, which mobile has plenty of at
    // the top of the screen. Either way, the utility pill only takes
    // up room while it's actually open.
    return isMobile
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: mainPill),
                  const SizedBox(width: 8),
                  moreButton,
                ],
              ),
              if (_utilityOpen) const SizedBox(height: 8),
              utilityPill,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: mainPill),
              const SizedBox(width: 8),
              moreButton,
              if (_utilityOpen) const SizedBox(width: 10),
              utilityPill,
            ],
          );
  }
}

/// Shared frosted-glass pill shell used by both the main nav bar and the
/// separate theme/language utility bar, so the two look like one family
/// of controls even though they're now two distinct pills.
class _GlassPill extends StatelessWidget {
  final Widget child;
  final bool isMobile;

  const _GlassPill({required this.child, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 16,
            vertical: isMobile ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface.withOpacity(0.55),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.colors.cream.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The small "more" button at the end of the main pill. Tapping it shows
/// or hides the theme/language utility pill — it never lights up like a
/// page icon (it doesn't navigate anywhere), it just flips its own
/// background between resting and "open" to hint at the toggle state.
class _MoreToggleButton extends StatelessWidget {
  final bool open;
  final VoidCallback onTap;

  const _MoreToggleButton({required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: open
                ? context.colors.orchid.withOpacity(0.32)
                : context.colors.orchid.withOpacity(0.14),
          ),
          child: Icon(
            Icons.more_vert_rounded,
            size: 20,
            color: open ? context.colors.cream : context.colors.creamDim,
          ),
        ),
      ),
    );
  }
}

/// EN/AR switch. Flips the storefront's language *and* its Arabic font
/// together, in one tap, so the two never drift out of sync — Arabic
/// language always shows in the Cairo typeface defined in [AppFonts],
/// the same Arabic face used everywhere else in the app's design system.
/// Only ever touches [LanguageController]/[FontController]; the admin
/// dashboard doesn't read either one, so it's unaffected and stays English.
class _LanguageToggle extends StatelessWidget {
  final bool isArabic;
  final bool isMobile;

  const _LanguageToggle({required this.isArabic, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.languageController.toggleLanguage();
          context.fontController.toggleArabicMode();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 7, vertical: isMobile ? 6 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.colors.creamDim.withOpacity(0.35)),
          ),
          child: Text(
            isArabic ? 'EN' : 'AR',
            style: AppFonts.label(
              size: isMobile ? 13 : 12,
              color: context.colors.cream,
              letterSpacing: 1.0,
              weight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// A single icon (+ optional label) in the nav bar. Sits at a fixed, small
/// resting size, and pops up larger with a glowing backdrop the moment a
/// pointer hovers or presses it — then eases straight back down the
/// instant that pointer leaves or lifts. The scale/glow live entirely on
/// this one item, so growing one icon never nudges its neighbours or the
/// bar's overall size.
class _NavIconLabel extends StatefulWidget {
  final IconData icon;
  final String? label;
  final bool active;
  final int? badge;
  final VoidCallback onTap;
  final bool isMobile;
  /// When true, renders the label in a small caption under the icon
  /// instead of beside it — used on mobile, where the nav bar is too
  /// narrow for the desktop's side-by-side icon + label layout.
  final bool stacked;

  const _NavIconLabel({
    required this.icon,
    this.label,
    required this.active,
    this.badge,
    required this.onTap,
    this.isMobile = false,
    this.stacked = false,
  });

  @override
  State<_NavIconLabel> createState() => _NavIconLabelState();
}

class _NavIconLabelState extends State<_NavIconLabel> {
  bool _hovered = false;
  bool _pressed = false;

  // Only reacts to the icon's own page actually being open (i.e. it was
  // clicked), plus a brief press-down feedback. Hovering the mouse over
  // it on desktop no longer pops it up on its own.
  bool get _expanded => widget.active || _pressed;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active;
    final color = highlighted ? context.colors.cream : context.colors.creamDim;

    final iconSize = widget.isMobile ? 25.0 : 20.0;

    final iconWithBadge = Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(widget.icon, size: iconSize, color: color),
        if (widget.badge != null)
          Positioned(
            top: -7,
            right: -9,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: context.colors.violetGradient,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
              child: Text(
                '${widget.badge}',
                textAlign: TextAlign.center,
                style: AppFonts.label(
                  size: 11.5,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
      ],
    );

    // Mobile: icon with a small caption stacked underneath, so the label
    // is visible without widening the bar the way the desktop's
    // side-by-side layout would.
    final content = widget.stacked
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWithBadge,
              if (widget.label != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.label!,
                  style: AppFonts.label(size: 13.5, color: color, letterSpacing: 0.6)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWithBadge,
              if (widget.label != null) ...[
                const SizedBox(width: 7),
                Text(
                  widget.label!,
                  style: AppFonts.label(size: 12.5, color: color, letterSpacing: 1.0)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ],
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        // Listener reports the raw finger/mouse down-and-up directly — it
        // never enters the tap gesture arena, so it can't be delayed or
        // cancelled the way GestureDetector's onTapDown/onTapUp sometimes
        // were on touch, which is what made the grow effect unreliable on
        // phones. The GestureDetector below still handles the actual tap
        // (navigation) exactly as before.
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
          // Margin only handles spacing between nav items now — it stays
          // fixed so items don't shove each other around. Everything
          // that visually grows (background box, shadow, icon, label)
          // lives together inside the AnimatedScale below, so they all
          // scale up and down as one single, proportioned unit instead
          // of the icon ballooning past a background box that stayed
          // put-size.
          margin: EdgeInsets.symmetric(horizontal: widget.stacked ? 5 : (widget.label != null ? 4 : 3)),
          child: AnimatedScale(
            // Mobile gets a much bigger pop than desktop — the bar has
            // more spare room stacked vertically per icon, so the active
            // icon can grow a lot more without crowding its neighbours.
            scale: _expanded ? (widget.isMobile ? 1.15 : 1.18) : 1.0,
            // Same duration/curve whether growing or shrinking, so when
            // one icon pops up the instant another settles back down,
            // the two motions feel like one balanced, synced animation
            // instead of a bounce racing a slower ease.
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.symmetric(
                horizontal: widget.stacked ? 6 : (widget.label != null ? 8 : 6),
                vertical: widget.stacked ? 6 : 6,
              ),
              decoration: BoxDecoration(
                border: widget.stacked
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: widget.active ? context.colors.orchid : Colors.transparent,
                          width: 2,
                        ),
                      ),
                borderRadius: BorderRadius.circular(widget.stacked ? 12 : 100),
                color: null,
                boxShadow: widget.active
                    ? [
                        BoxShadow(
                          color: context.colors.orchid.withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ]
                    : const [],
              ),
              child: content,
            ),
          ),
        ),
        ),
      ),
    );
  }
}
