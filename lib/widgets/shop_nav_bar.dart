import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../providers/cart_provider.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';

enum ShopPage { home, shop, search, services, about, cart }

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
///
/// The theme (light/dark) and language (EN/AR) toggles live directly in
/// this same pill now, right after the page icons — they used to hide
/// behind a separate "more" button/pill that had to be opened first, but
/// they're common enough controls that they belong in the bar itself.
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
                    size: isMobile ? 17 : 16.5,
                    weight: FontWeight.w800,
                    color: context.colors.cream,
                    letterSpacing: 1.0,
                    // The wordmark is always Latin text and the nav bar is
                    // meant to stay a fixed, compact size in either
                    // language — don't let the Arabic-mode size boost
                    // (meant for actual Arabic copy) inflate it.
                    boostArabicSize: false,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 11),
              if (!isMobile) ...[
                _NavIconLabel(
                  icon: active == ShopPage.home
                      ? Icons.home_rounded
                      : Icons.home_outlined,
                  label: strings.navHome,
                  active: active == ShopPage.home,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.home),
                ),
                _NavIconLabel(
                  icon: active == ShopPage.shop
                      ? Icons.storefront_rounded
                      : Icons.storefront_outlined,
                  label: strings.navShop,
                  active: active == ShopPage.shop,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.shop),
                ),
                _NavIconLabel(
                  icon: active == ShopPage.search
                      ? Icons.search_rounded
                      : Icons.search_outlined,
                  label: strings.navSearch,
                  active: active == ShopPage.search,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.search),
                ),
                _NavIconLabel(
                  icon: active == ShopPage.services
                      ? Icons.design_services_rounded
                      : Icons.design_services_outlined,
                  label: strings.navServices,
                  active: active == ShopPage.services,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.services),
                ),
                _NavIconLabel(
                  icon: active == ShopPage.about
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  label: strings.navAbout,
                  active: active == ShopPage.about,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.about),
                ),
              ],
              _NavIconLabel(
                icon: active == ShopPage.cart
                    ? Icons.shopping_bag_rounded
                    : Icons.shopping_bag_outlined,
                label: strings.navCart,
                stacked: isMobile,
                active: active == ShopPage.cart,
                isMobile: isMobile,
                badge: cartCount > 0 ? cartCount : null,
                onTap: () => onTap(ShopPage.cart),
              ),
              if (isMobile) ...[
                _NavIconLabel(
                  icon: active == ShopPage.shop
                      ? Icons.storefront_rounded
                      : Icons.storefront_outlined,
                  label: strings.navShop,
                  stacked: true,
                  active: active == ShopPage.shop,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.shop),
                ),
                _NavIconLabel(
                  icon: active == ShopPage.search
                      ? Icons.search_rounded
                      : Icons.search_outlined,
                  label: strings.navSearch,
                  stacked: true,
                  active: active == ShopPage.search,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.search),
                ),
                _NavIconLabel(
                  icon: active == ShopPage.services
                      ? Icons.design_services_rounded
                      : Icons.design_services_outlined,
                  label: strings.navServices,
                  stacked: true,
                  active: active == ShopPage.services,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.services),
                ),
                _NavIconLabel(
                  icon: active == ShopPage.about
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  label: strings.navAbout,
                  stacked: true,
                  active: active == ShopPage.about,
                  isMobile: isMobile,
                  onTap: () => onTap(ShopPage.about),
                ),
              ],
              // Small divider so the theme/language toggles read as their
              // own group instead of blending into the page icons.
              Container(
                width: 1,
                height: isMobile ? 18 : 17,
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 5 : 5),
                color: context.colors.border(0.25),
              ),
              // Theme (light/dark) and language (EN/AR) toggles now live
              // right here in the main pill alongside the page icons,
              // instead of behind a separate "more" button that had to be
              // opened first.
              _NavIconLabel(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                active: false,
                isMobile: isMobile,
                onTap: () => context.themeController.toggleTheme(),
              ),
              _LanguageToggle(isArabic: isArabic, isMobile: isMobile),
      ],
    );

    return _GlassPill(
      isMobile: isMobile,
      child: isMobile
          ? FittedBox(fit: BoxFit.scaleDown, child: row)
          : row,
    );
  }
}

/// Compact top bar shown on mobile in place of the full pill nav — just a
/// menu button that opens the [ShopNavDrawer], the wordmark, and a cart
/// shortcut with its live item-count badge. Cart stays one tap away even
/// though the rest of the nav (Shop/Search/Services + theme/language) has
/// moved into the drawer, since jumping straight to the cart is common
/// enough on a storefront to deserve its own spot in the bar.
class ShopMobileTopBar extends StatelessWidget {
  final ShopPage active;
  final ValueChanged<ShopPage> onTap;
  final VoidCallback onMenuTap;

  const ShopMobileTopBar({
    super.key,
    required this.active,
    required this.onTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return _GlassPill(
      isMobile: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavIconLabel(
            icon: Icons.menu_rounded,
            active: false,
            isMobile: true,
            onTap: onMenuTap,
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onTap(ShopPage.home),
            // Same plain, solid-colored wordmark as the full pill — see the
            // note in ShopNavBar.build() about ShaderMask + BackdropFilter
            // not playing nicely together on Flutter Web.
            child: Text(
              "Aya's",
              style: AppFonts.display(
                size: 17,
                weight: FontWeight.w800,
                color: context.colors.cream,
                letterSpacing: 1.0,
                boostArabicSize: false,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _NavIconLabel(
            icon: active == ShopPage.cart
                ? Icons.shopping_bag_rounded
                : Icons.shopping_bag_outlined,
            active: active == ShopPage.cart,
            isMobile: true,
            badge: cartCount > 0 ? cartCount : null,
            onTap: () => onTap(ShopPage.cart),
          ),
        ],
      ),
    );
  }
}

/// Slide-out nav drawer that replaces the full pill nav on mobile. Holds
/// the same page links (Shop, Search, Services, Cart) plus the theme and
/// language toggles that used to live in the pill — laid out as a vertical
/// list here since a phone screen is too narrow to fit all of them in one
/// bar without shrinking every icon down to the point of being fiddly to
/// tap. Opens from the side Directionality puts first (left in English,
/// right in Arabic), which Flutter's Drawer handles automatically.
class ShopNavDrawer extends StatelessWidget {
  final ShopPage active;
  final ValueChanged<ShopPage> onTap;

  const ShopNavDrawer({super.key, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final isDark = context.watch<ThemeController>().isDark;
    final isArabic = context.watch<LanguageController>().isArabic;
    final strings = context.strings;

    // Closes the drawer first, then navigates — otherwise the drawer stays
    // open (or its close animation visibly races the page swap) instead of
    // reading as one clean "pick a page" tap.
    void go(ShopPage page) {
      Navigator.of(context).pop();
      onTap(page);
    }

    return Drawer(
      backgroundColor: Colors.transparent,
      width: 280,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: context.colors.surface.withOpacity(0.94),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                    child: Text(
                      "Aya's",
                      style: AppFonts.display(
                        size: 26,
                        weight: FontWeight.w800,
                        color: context.colors.cream,
                        letterSpacing: 1.0,
                        boostArabicSize: false,
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: active == ShopPage.home
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    label: strings.navHome,
                    active: active == ShopPage.home,
                    onTap: () => go(ShopPage.home),
                  ),
                  _DrawerItem(
                    icon: active == ShopPage.shop
                        ? Icons.storefront_rounded
                        : Icons.storefront_outlined,
                    label: strings.navShop,
                    active: active == ShopPage.shop,
                    onTap: () => go(ShopPage.shop),
                  ),
                  _DrawerItem(
                    icon: active == ShopPage.search
                        ? Icons.search_rounded
                        : Icons.search_outlined,
                    label: strings.navSearch,
                    active: active == ShopPage.search,
                    onTap: () => go(ShopPage.search),
                  ),
                  _DrawerItem(
                    icon: active == ShopPage.services
                        ? Icons.design_services_rounded
                        : Icons.design_services_outlined,
                    label: strings.navServices,
                    active: active == ShopPage.services,
                    onTap: () => go(ShopPage.services),
                  ),
                  _DrawerItem(
                    icon: active == ShopPage.about
                        ? Icons.person_rounded
                        : Icons.person_outline_rounded,
                    label: strings.navAbout,
                    active: active == ShopPage.about,
                    onTap: () => go(ShopPage.about),
                  ),
                  _DrawerItem(
                    icon: active == ShopPage.cart
                        ? Icons.shopping_bag_rounded
                        : Icons.shopping_bag_outlined,
                    label: strings.navCart,
                    active: active == ShopPage.cart,
                    badge: cartCount > 0 ? cartCount : null,
                    onTap: () => go(ShopPage.cart),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Divider(
                      color: context.colors.border(0.25),
                      height: 1,
                    ),
                  ),
                  _DrawerItem(
                    icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    label: isDark
                        ? (isArabic ? 'الوضع الفاتح' : 'Light mode')
                        : (isArabic ? 'الوضع الداكن' : 'Dark mode'),
                    active: false,
                    onTap: () => context.themeController.toggleTheme(),
                  ),
                  _DrawerItem(
                    icon: Icons.translate_rounded,
                    label: isArabic ? 'English' : 'العربية',
                    active: false,
                    onTap: () {
                      context.languageController.toggleLanguage();
                      context.fontController.toggleArabicMode();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single tappable row in [ShopNavDrawer] — an icon, a label, and (for
/// the active page) a filled violet-gradient pill background so the
/// current page reads clearly at a glance down the list.
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final int? badge;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.active,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : context.colors.creamDim;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: active ? context.colors.violetGradient : null,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: color),
                if (badge != null)
                  Positioned(
                    top: -6,
                    right: -9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: context.colors.violetGradient,
                        shape: BoxShape.circle,
                        border: active ? Border.all(color: Colors.white, width: 1.2) : null,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$badge',
                        textAlign: TextAlign.center,
                        style: AppFonts.label(
                          size: 10.5,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppFonts.label(
                  size: 15,
                  color: color,
                  letterSpacing: 0.4,
                ).copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
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
            horizontal: isMobile ? 16 : 17,
            vertical: isMobile ? 9 : 9,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface.withOpacity(0.55),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: context.colors.border(0.08)),
          ),
          child: child,
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
            border: Border.all(color: context.colors.border(0.35)),
          ),
          child: Text(
            isArabic ? 'EN' : 'AR',
            // This label is always Latin ("EN"/"AR") — keep it a fixed
            // size regardless of which language is active.
            style: AppFonts.label(
              size: isMobile ? 11 : 11,
              color: context.colors.cream,
              letterSpacing: 1.0,
              weight: FontWeight.w700,
              boostArabicSize: false,
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

  // Active page, a brief press-down, or simply hovering (desktop) all
  // grow the icon+label as one unit — active/inactive itself is shown
  // by the icon's shape (filled vs. outline) instead, see build() below.
  bool get _expanded => widget.active || _pressed || _hovered;

  @override
  Widget build(BuildContext context) {
    final color = _expanded ? context.colors.cream : context.colors.creamDim;

    final iconSize = widget.isMobile ? 21.0 : 19.0;

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
                  // boostArabicSize: false — nav labels stay the same
                  // compact size in Arabic as in English, matching the
                  // bar's fixed footprint instead of growing with the
                  // Arabic-mode font boost.
                  style: AppFonts.label(
                    size: 11.5,
                    color: color,
                    letterSpacing: 0.6,
                    boostArabicSize: false,
                  ).copyWith(fontWeight: FontWeight.w700),
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
                  // Same fix as the stacked (mobile) label above, for the
                  // desktop side-by-side layout.
                  style: AppFonts.label(
                    size: widget.isMobile ? 11.5 : 14.5,
                    color: color,
                    letterSpacing: 1.0,
                    boostArabicSize: false,
                  ).copyWith(fontWeight: FontWeight.w600),
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
          margin: EdgeInsets.symmetric(horizontal: widget.stacked ? 4 : (widget.label != null ? 4 : 3)),
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
                horizontal: widget.stacked ? 5 : (widget.label != null ? 8 : 6),
                vertical: widget.stacked ? 5 : 6,
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
