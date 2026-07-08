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
class ShopNavBar extends StatelessWidget {
  final ShopPage active;
  final ValueChanged<ShopPage> onTap;
  final bool isMobile;

  const ShopNavBar({
    super.key,
    required this.active,
    required this.onTap,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
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
              SizedBox(width: isMobile ? 16 : 18),
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
              _NavIconLabel(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                active: false,
                isMobile: isMobile,
                onTap: () => context.themeController.toggleTheme(),
              ),
              _LanguageToggle(isArabic: isArabic, isMobile: isMobile),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 18,
            vertical: isMobile ? 12 : 10,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface.withOpacity(0.55),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.colors.cream.withOpacity(0.08)),
          ),
          // On mobile the bar can be wider than the screen once every
          // icon + stacked label + toggle is laid out side by side.
          // FittedBox scales the whole pill down just enough to keep
          // every item on screen at once, instead of letting the
          // ClipRRect above silently clip the right edge off.
          child: isMobile
              ? FittedBox(fit: BoxFit.scaleDown, child: row)
              : row,
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
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 6),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 13 : 12, vertical: isMobile ? 8 : 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.colors.creamDim.withOpacity(0.35)),
          ),
          child: Text(
            isArabic ? 'EN' : 'AR',
            style: AppFonts.label(
              size: isMobile ? 14 : 12.5,
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

  // Stays big for as long as this icon's own page is the one currently
  // open — not just while a pointer happens to be hovering or pressing
  // it. Hover/press still work too, for the icons that aren't active.
  bool get _expanded => widget.active || _hovered || _pressed;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;
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
                  style: AppFonts.label(size: 12.5, color: color, letterSpacing: 0.6)
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
          margin: EdgeInsets.symmetric(horizontal: widget.stacked ? 5 : (widget.label != null ? 6 : 4)),
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
            borderRadius: widget.stacked ? BorderRadius.circular(12) : null,
            color: widget.stacked && widget.active
                ? context.colors.orchid.withOpacity(0.14)
                : null,
          ),
          // A tiny bit of extra breathing room around the icon so it has
          // somewhere to grow into without visually colliding with its
          // neighbours when it pops up.
          child: AnimatedScale(
            // Mobile gets a much bigger pop than desktop — the bar has
            // more spare room stacked vertically per icon, so the active
            // icon can grow a lot more without crowding its neighbours.
            scale: _expanded ? (widget.isMobile ? 2.6 : 1.35) : 1.0,
            // Same duration/curve whether growing or shrinking, so when
            // one icon pops up the instant another settles back down,
            // the two motions feel like one balanced, synced animation
            // instead of a bounce racing a slower ease.
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
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
