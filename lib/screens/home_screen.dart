import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/home_banner.dart';
import '../models/illustration_art_item.dart';
import '../models/product.dart';
import '../providers/language_controller.dart';
import '../services/categories_repository.dart';
import '../services/illustration_art_repository.dart';
import '../services/service_categories_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/circle_carousel.dart';
import '../widgets/home_banner_slideshow.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/owner_intro_card.dart';
import '../widgets/product_grid.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_heading.dart';
import '../widgets/testimonials_section.dart';
import 'admin/admin_login_screen.dart';
import 'graphical_services_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Product> products;
  final bool isMobile;
  final ScrollController scrollController;
  final VoidCallback? onAdminReturn;
  // Started earlier, in MainShell's initState, at the same time as the
  // products fetch — see the comment there for why. HomeScreen just
  // awaits it instead of kicking off its own fetch after mounting.
  final Future<List<HomeBanner>> bannersFuture;
  // Services no longer lives on Home — it's its own tab now (see
  // MainShell). The little "service circles" row below still appears
  // here, though: tapping one calls this to jump to the Services tab
  // and land on (and scroll to) that specific category there — see
  // MainShell._openServiceCategory.
  final ValueChanged<int> onServiceCategoryTap;
  // The shop grid itself lives on its own standalone Shop tab now (see
  // ShopScreen / MainShell) — Home just teases the collection. The
  // hero's "Shop the collection" button calls this to switch straight
  // to that tab.
  final VoidCallback onShopTap;
  // Tapping one of the product category circles below used to filter
  // this same page's shop grid in place; now it jumps to the Shop tab
  // with that category already selected — see
  // MainShell._openShopCategory.
  final ValueChanged<String> onCategoryTap;
  // "Who am I" no longer lives embedded on Home — it's the standalone
  // Portfolio tab now (see MainShell). The owner-intro card's "View full
  // profile" button calls this to switch straight to that tab.
  final VoidCallback onViewProfileTap;

  const HomeScreen({
    super.key,
    required this.products,
    required this.isMobile,
    required this.scrollController,
    this.onAdminReturn,
    required this.bannersFuture,
    required this.onServiceCategoryTap,
    required this.onShopTap,
    required this.onCategoryTap,
    required this.onViewProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Owner-set category thumbnails from the dashboard, keyed by category
  // name. A category with no entry here (or an empty imageUrl) falls back
  // to that category's first product photo instead.
  Map<String, String> _categoryImages = {};
  // Owner-set thumbnails for the 3 fixed service circles (Mentoring /
  // Designing / Private Workshop), keyed by their index in
  // kServiceCategories. No entry falls back to that category's icon —
  // see _ServicesSection below.
  Map<int, String> _serviceCategoryImages = {};
  // Owner-managed "Illustration & Art" circles — fully open-ended, added/
  // edited/reordered from the admin dashboard. Fetched once up front, same
  // as the banners future above.
  late Future<List<IllustrationArtItem>> _illustrationArtFuture;

  @override
  void initState() {
    super.initState();
    _loadCategoryImages();
    _loadServiceCategoryImages();
    _illustrationArtFuture = IllustrationArtRepository.fetchAll();
  }

  Future<void> _loadCategoryImages() async {
    final items = await CategoriesRepository.fetchAllWithImages();
    if (!mounted) return;
    setState(() {
      _categoryImages = {
        for (final c in items)
          if (c.imageUrl.isNotEmpty) c.name: c.imageUrl,
      };
    });
  }

  Future<void> _loadServiceCategoryImages() async {
    final images = await ServiceCategoriesRepository.fetchImages();
    if (!mounted) return;
    setState(() => _serviceCategoryImages = images);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        children: [
          SizedBox(height: widget.isMobile ? 120 : 150),
          FutureBuilder<List<HomeBanner>>(
            future: widget.bannersFuture,
            builder: (context, snapshot) {
              return _Hero(
                isMobile: widget.isMobile,
                banners: snapshot.data ?? const [],
              );
            },
          ),
          const SizedBox(height: 40),
          MarqueeStrip(
            height: 60,
            words: [
            context.strings.marqueeNotebooks,
            context.strings.marqueeCalendars,
            context.strings.marqueeBookmark,
            context.strings.marqueeStand,
          ]),
          const SizedBox(height: 48),
          _ServicesSection(
            serviceCategoryImages: _serviceCategoryImages,
            isMobile: widget.isMobile,
            onServiceCategoryTap: widget.onServiceCategoryTap,
          ),
          const SizedBox(height: 88),
          FutureBuilder<List<IllustrationArtItem>>(
            future: _illustrationArtFuture,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const [];
              if (items.isEmpty) return const SizedBox.shrink();
              return _IllustrationArtSection(items: items, isMobile: widget.isMobile);
            },
          ),
          if (widget.products.isNotEmpty) ...[
            const SizedBox(height: 88),
            _ShopPreviewSection(
              products: widget.products,
              isMobile: widget.isMobile,
              onProductTap: (product) => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
              ),
              onShopTap: widget.onShopTap,
            ),
          ],
          const SizedBox(height: 32),
          // Soft divider to separate "Shop the collection" from
          // "Available for" below it.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 40 : 120),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    context.colors.border(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // "Available for" now sits right under "Shop the collection" —
          // moved down from its old spot after the marquee.
          OwnerIntroCard(
            isMobile: widget.isMobile,
            onViewProfile: widget.onViewProfileTap,
            onAudienceTap: widget.onServiceCategoryTap,
          ),
          const SizedBox(height: 40),
          TestimonialsSection(isMobile: widget.isMobile),
          const SizedBox(height: 60),
          _Footer(isMobile: widget.isMobile, onAdminReturn: widget.onAdminReturn),
        ],
      ),
    );
  }
}

class _Hero extends StatefulWidget {
  final bool isMobile;
  final List<HomeBanner> banners;
  const _Hero({required this.isMobile, required this.banners});

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  // Drives the dot row directly under the slideshow — the slideshow
  // itself no longer draws dots over the photo (showDots: false below),
  // so this is the only thing tracking which slide is active.
  int _bannerPage = 0;

  bool get isMobile => widget.isMobile;
  List<HomeBanner> get banners => widget.banners;

  @override
  Widget build(BuildContext context) {
    // Banners are one owner-uploaded photo — no separate mobile/desktop
    // crop — so the frame now keeps one fixed aspect ratio at every screen
    // size instead of sizing off viewport height. That old approach (55%
    // of screen height on phone, 92% on desktop) gave the container a
    // completely different shape on each, so a photo cropped well on one
    // came out wrong on the other. A 16:9 frame is the same relative crop
    // everywhere — only the overall size scales with the available width.
    // Clamped at both ends so very narrow phones and very wide desktop
    // monitors still get a sensible height.
    final screenWidth = MediaQuery.of(context).size.width;
    // Mobile now goes edge-to-edge (no side gutters) so the banner fills
    // the screen left/right like a native app hero; desktop keeps its
    // original inset frame.
    final horizontalPadding = isMobile ? 0.0 : 60.0;
    final availableWidth = screenWidth - horizontalPadding * 2;
    const bannerAspectRatio = 16 / 9;
    final bannerHeight = (availableWidth / bannerAspectRatio).clamp(200.0, 760.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Both the wordmark and the "NOTEBOOKS & CALENDARS" eyebrow line
          // are gone now — the sliders are the very first thing in the
          // hero, with the dots directly underneath them.
          if (banners.isNotEmpty) ...[
            HomeBannerSlideshow(
              banners: banners,
              height: bannerHeight.toDouble(),
              showDots: false,
              onPageChanged: (i) => setState(() => _bannerPage = i),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (i) {
                  final active = i == _bannerPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? context.colors.orchid : context.colors.creamDim.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// A compact section dropped right under the marquee: an eyebrow pill
/// reading "SERVICES", a divider, then the three fixed service circles
/// (Mentoring / Designing / Private Workshop) centered in a row. Each
/// jumps straight to that category on the standalone Services tab.
class _ServicesSection extends StatelessWidget {
  final Map<int, String> serviceCategoryImages;
  final bool isMobile;
  final ValueChanged<int> onServiceCategoryTap;

  const _ServicesSection({
    required this.serviceCategoryImages,
    required this.isMobile,
    required this.onServiceCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageController>().isArabic;
    return _EyebrowCirclesSection(
      icon: Icons.design_services_outlined,
      eyebrow: context.strings.homeServicesEyebrow,
      isMobile: isMobile,
      desktopDiameter: 188,
      specs: [
        for (var i = 0; i < kServiceCategories.length; i++)
          _CircleSpec(
            label: kServiceCategories[i].title.t(isArabic),
            imageUrl: serviceCategoryImages[i],
            icon: kServiceCategories[i].icon,
            onTap: () => onServiceCategoryTap(i),
          ),
      ],
    );
  }
}

/// The owner-managed "Illustration & Art" row: same eyebrow-pill-plus-
/// divider treatment as [_ServicesSection] right above it, but the
/// circles here are a fully open-ended list the owner adds/edits/deletes/
/// reorders from the admin dashboard (see AdminIllustrationArtScreen)
/// instead of a fixed set of three. Hidden entirely until the owner has
/// added at least one circle — see the empty-check at the call site.
class _IllustrationArtSection extends StatelessWidget {
  final List<IllustrationArtItem> items;
  final bool isMobile;

  const _IllustrationArtSection({required this.items, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageController>().isArabic;
    return _EyebrowCirclesSection(
      icon: Icons.palette_outlined,
      eyebrow: context.strings.illustrationArtEyebrow,
      isMobile: isMobile,
      desktopDiameter: 188,
      specs: [
        for (var i = 0; i < items.length; i++)
          _CircleSpec(
            label: items[i].title(isArabic),
            imageUrl: items[i].imageUrl,
            onTap: () {},
          ),
      ],
    );
  }
}

/// Teases the shop from Home: a handful of products in a grid, followed by
/// a "Shop the collection" pill button that hands off to the standalone
/// Shop tab (see [HomeScreen.onShopTap]) — the full grid, category filter,
/// and best-sellers section all live over there now (see ShopScreen).
/// Capped at 8 products so Home stays a teaser rather than a second full
/// listing.
class _ShopPreviewSection extends StatelessWidget {
  final List<Product> products;
  final bool isMobile;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onShopTap;

  const _ShopPreviewSection({
    required this.products,
    required this.isMobile,
    required this.onProductTap,
    required this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final preview = products.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: RevealOnScroll(
              child: SectionHeading(
                eyebrow: context.strings.mostRequestedEyebrow,
                title: context.strings.artisticProductsLabel,
                titleSize: isMobile ? 24 : 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          // Matches ShopScreen's outer horizontal inset (ProductGrid adds
          // its own inner padding on top of this in both places) so the
          // grid ends up the same effective width — and the cards the
          // same size — on both Home and the Shop tab.
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
          child: ProductGrid(products: preview, onProductTap: onProductTap),
        ),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: onShopTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
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
                context.strings.shopTheCollection,
                style: AppFonts.label(size: 16, color: Colors.white, letterSpacing: 0.5)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shared eyebrow-pill + divider + centered circle row, used by both
/// [_ServicesSection] and [_IllustrationArtSection] so they stay visually
/// identical (same treatment as the "AVAILABLE FOR" / "MOST REQUESTED"
/// sections further down the page).
class _EyebrowCirclesSection extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final bool isMobile;
  final List<_CircleSpec> specs;
  final double desktopDiameter;

  const _EyebrowCirclesSection({
    required this.icon,
    required this.eyebrow,
    required this.isMobile,
    required this.specs,
    required this.desktopDiameter,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // On desktop there's room for every circle side by side at full size,
    // so it stays the plain centered Wrap it always was. On mobile that
    // same size wraps one-per-line (see the old screenshot this was
    // fixed from), so instead it's a single horizontal row of smaller
    // circles that periodically swap places — see MobileCircleCarousel.
    final circlesArea = isMobile
        ? MobileCircleCarousel(
            itemCount: specs.length,
            // Titles can wrap onto a second line (see _CategoryCircle's
            // maxLines: 2), so reserve extra height below the circle for
            // it instead of the default single-line allowance.
            labelAreaHeight: 60,
            itemBuilder: (context, i, diameter) => _CategoryCircle(
              label: specs[i].label,
              imageUrl: specs[i].imageUrl,
              icon: specs[i].icon,
              diameter: diameter,
              // Smaller circles need a smaller label to still read as one
              // tidy line under each — desktop keeps its own value below.
              labelSize: (diameter * 0.15).clamp(13.0, 16.0),
              selected: true,
              onTap: specs[i].onTap,
            ),
          )
        : Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              for (var i = 0; i < specs.length; i++)
                _CategoryCircle(
                  label: specs[i].label,
                  imageUrl: specs[i].imageUrl,
                  icon: specs[i].icon,
                  diameter: desktopDiameter,
                  selected: true,
                  floatDelayIndex: i,
                  onTap: specs[i].onTap,
                ),
            ],
          );

    final content = Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMobile ? 14 : 17, color: colors.orchid),
            SizedBox(width: isMobile ? 7 : 10),
            Text(eyebrow,
                style: AppFonts.label(
                  color: colors.orchid,
                  size: isMobile ? 12.5 : 16,
                  letterSpacing: isMobile ? 1.2 : 3.0,
                )),
          ],
        ),
        const SizedBox(height: 20),
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
        circlesArea,
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
      child: RevealOnScroll(child: content),
    );
  }
}

/// A plain (label, image/icon, tap target) bundle for a category circle —
/// used instead of a built _CategoryCircle widget so the layout picked at
/// build time (desktop Wrap vs. mobile carousel) can each size the circles
/// however suits that layout, rather than inheriting one fixed diameter.
class _CircleSpec {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final VoidCallback onTap;

  const _CircleSpec({
    required this.label,
    this.imageUrl,
    this.icon,
    required this.onTap,
  });
}

class _CategoryCircle extends StatefulWidget {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final double diameter;
  final bool selected;
  final int floatDelayIndex;
  final VoidCallback onTap;
  // Font size for the label under the circle — defaults to the original
  // fixed desktop size; the mobile carousel passes a smaller value scaled
  // to its (smaller) diameter instead.
  final double labelSize;

  const _CategoryCircle({
    required this.label,
    this.imageUrl,
    this.icon,
    required this.diameter,
    required this.selected,
    this.floatDelayIndex = 0,
    required this.onTap,
    this.labelSize = 19,
  });

  @override
  State<_CategoryCircle> createState() => _CategoryCircleState();
}

class _CategoryCircleState extends State<_CategoryCircle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final diameter = widget.diameter;
    final selected = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: diameter + 16,
          child: Column(
            children: [
              // Instagram-story styling: a gradient ring always frames
              // the circle (not just when selected) — selecting it just
              // brightens it, same way a viewed vs. unviewed story ring
              // differs on Instagram. Shrinks slightly on hover as a
              // lightweight hint that it's tappable, no shadow/glow.
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
                    gradient: context.colors.violetGradient,
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.violetPop.withOpacity(0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.surface,
                      border: Border.all(color: context.colors.bgDeep, width: 2),
                    ),
                    child: ClipOval(
                      child: widget.imageUrl != null
                          ? Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                widget.icon ?? Icons.auto_awesome_rounded,
                                color: context.colors.creamDim,
                                size: diameter * 0.36,
                              ),
                            )
                          : Center(
                              child: Icon(
                                widget.icon ?? Icons.auto_awesome_rounded,
                                color: context.colors.creamDim,
                                size: diameter * 0.36,
                              ),
                            ),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFonts.label(
                  size: widget.labelSize,
                  weight: FontWeight.w600,
                  color: selected ? context.colors.cream : context.colors.creamDim,
                  letterSpacing: 0.6,
                  text: widget.label,
                ).copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _Footer extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onAdminReturn;
  const _Footer({required this.isMobile, this.onAdminReturn});

  Future<void> _openAdmin(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
    onAdminReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60, vertical: 32),
      decoration: BoxDecoration(
        // surfaceRaised, not surface: in light mode surface is pure white
        // (same as the page background), so it made this whole footer
        // invisible against the rest of Home — no visual separation at
        // all. surfaceRaised is a step darker/tinted in both palettes, so
        // it actually reads as its own band now.
        color: colors.surfaceRaised.withOpacity(colors.isDark ? 0.5 : 0.6),
        border: Border(top: BorderSide(color: colors.border(0.08))),
      ),
      child: Column(
        children: [
          // Plain solid color — see shop_nav_bar.dart / shimmer_text.dart
          // for why ShaderMask was dropped here (it wasn't painting).
          Text("Aya's Graphique",
              style: AppFonts.display(size: 22, weight: FontWeight.w800, color: context.colors.cream)),
          const SizedBox(height: 10),
          Text(
            context.strings.footerTagline,
            textAlign: TextAlign.center,
            style: AppFonts.body(color: context.colors.creamDim, size: 13),
          ),
          const SizedBox(height: 6),
          Text("© ${DateTime.now().year} Aya's Graphique ", style: AppFonts.body(color: context.colors.creamDim, size: 12)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _openAdmin(context),
            child: Text(
              context.strings.storeAdmin,
              style: AppFonts.label(size: 11, color: context.colors.creamDim, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
