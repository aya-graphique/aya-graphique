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
                    size: isMobile ? 20 : 23,
                    weight: FontWeight.w800,
                    color: context.colors.cream,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 18 : 26),
              if (!isMobile) ...[
                _NavIconLabel(
                  icon: Icons.storefront_rounded,
                  label: strings.navShop,
                  active: active == ShopPage.home,
                  onTap: () => onTap(ShopPage.home),
                ),
                _NavIconLabel(
                  icon: Icons.search_rounded,
                  label: strings.navSearch,
                  active: active == ShopPage.search,
                  onTap: () => onTap(ShopPage.search),
                ),
                _NavIconLabel(
                  icon: Icons.design_services_rounded,
                  label: strings.navServices,
                  active: active == ShopPage.services,
                  onTap: () => onTap(ShopPage.services),
                ),
                _NavIconLabel(
                  icon: Icons.person_outline_rounded,
                  label: strings.navAbout,
                  active: active == ShopPage.about,
                  onTap: () => onTap(ShopPage.about),
                ),
              ],
              _NavIconLabel(
                icon: Icons.shopping_bag_rounded,
                label: strings.navCart,
                stacked: isMobile,
                active: active == ShopPage.cart,
                badge: cartCount > 0 ? cartCount : null,
                onTap: () => onTap(ShopPage.cart),
              ),
              if (isMobile) ...[
                _NavIconLabel(
                  icon: Icons.search_rounded,
                  label: strings.navSearch,
                  stacked: true,
                  active: active == ShopPage.search,
                  onTap: () => onTap(ShopPage.search),
                ),
                _NavIconLabel(
                  icon: Icons.design_services_rounded,
                  label: strings.navServices,
                  stacked: true,
                  active: active == ShopPage.services,
                  onTap: () => onTap(ShopPage.services),
                ),
                _NavIconLabel(
                  icon: Icons.person_outline_rounded,
                  label: strings.navAbout,
                  stacked: true,
                  active: active == ShopPage.about,
                  onTap: () => onTap(ShopPage.about),
                ),
              ],
              _NavIconLabel(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                active: false,
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
            horizontal: isMobile ? 20 : 30,
            vertical: isMobile ? 12 : 18,
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
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 9),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 13 : 16, vertical: isMobile ? 8 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.colors.creamDim.withOpacity(0.35)),
          ),
          child: Text(
            isArabic ? 'EN' : 'AR',
            style: AppFonts.label(
              size: isMobile ? 13 : 15,
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

class _NavIconLabel extends StatefulWidget {
  final IconData icon;
  final String? label;
  final bool active;
  final int? badge;
  final VoidCallback onTap;
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
    this.stacked = false,
  });

  @override
  State<_NavIconLabel> createState() => _NavIconLabelState();
}

class _NavIconLabelState extends State<_NavIconLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;
    final color = highlighted ? context.colors.cream : context.colors.creamDim;

    final iconSize = widget.stacked ? 24.0 : 26.0;

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
                  style: AppFonts.label(size: 11.5, color: color, letterSpacing: 0.6)
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
                const SizedBox(width: 10),
                Text(
                  widget.label!,
                  style: AppFonts.label(size: 15.5, color: color, letterSpacing: 1.2)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: widget.stacked ? 5 : (widget.label != null ? 9 : 6)),
          padding: EdgeInsets.symmetric(
            horizontal: widget.stacked ? 6 : (widget.label != null ? 12 : 9),
            vertical: widget.stacked ? 6 : 9,
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
          child: content,
        ),
      ),
    );
  }
}
