import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/home_banner.dart';
import '../models/product.dart';
import '../providers/language_controller.dart';
import '../services/categories_repository.dart';
import '../services/service_categories_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/home_banner_slideshow.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/owner_intro_card.dart';
import '../widgets/product_grid.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_heading.dart';
import 'admin/admin_login_screen.dart';
import 'graphical_services_screen.dart';
import 'product_detail_screen.dart';
import 'who_am_i_screen.dart';

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

  const HomeScreen({
    super.key,
    required this.products,
    required this.isMobile,
    required this.scrollController,
    this.onAdminReturn,
    required this.bannersFuture,
    required this.onServiceCategoryTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _activeCategory;
  // Owner-set category thumbnails from the dashboard, keyed by category
  // name. A category with no entry here (or an empty imageUrl) falls back
  // to that category's first product photo instead — see
  // _CategoryCircles._thumbFor.
  Map<String, String> _categoryImages = {};
  // Owner-set thumbnails for the 3 fixed service circles (Mentoring /
  // Designing / Private Workshop), keyed by their index in
  // kServiceCategories. No entry falls back to that category's icon —
  // see _CategoryCircles below.
  Map<int, String> _serviceCategoryImages = {};
  // Lets the new owner-intro card's "View full profile" button scroll
  // straight down to the full "Who am I" section further down this same
  // page (see build() below and OwnerIntroCard).
  final GlobalKey _whoAmIKey = GlobalKey();
  // Lets the hero's "Shop the collection" button scroll straight down to
  // the products section further down this same page (see build() below
  // and _Hero).
  final GlobalKey _collectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadCategoryImages();
    _loadServiceCategoryImages();
  }

  void _scrollToProfile() {
    final ctx = _whoAmIKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
  }

  void _scrollToCollection() {
    final ctx = _collectionKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
      alignment: 0.05,
    );
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

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.products.map((p) => p.category).toSet().toList()..sort();
    final filtered = _activeCategory == null
        ? widget.products
        : widget.products.where((p) => p.category == _activeCategory).toList();
    // Real sales data only — a brand new store with no orders yet just
    // shows no "Best sellers" section instead of a misleading one.
    final topSellers = widget.products.where((p) => p.salesCount > 0).toList()
      ..sort((a, b) => b.salesCount.compareTo(a.salesCount));
    final bestSellers = topSellers.take(8).toList();

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
                onShopTap: _scrollToCollection,
              );
            },
          ),
          const SizedBox(height: 40),
          MarqueeStrip(words: [
            context.strings.marqueeNotebooks,
            context.strings.marqueeCalendars,
            context.strings.marqueeBookmark,
            context.strings.marqueeStand,
          ]),
          const SizedBox(height: 40),
          _CategoryCircles(
            products: widget.products,
            categories: categories,
            categoryImages: _categoryImages,
            serviceCategoryImages: _serviceCategoryImages,
            active: _activeCategory,
            isMobile: widget.isMobile,
            onSelect: (c) => setState(() => _activeCategory = c),
            onServiceCategoryTap: widget.onServiceCategoryTap,
          ),
          // Services now lives on its own tab (see MainShell) — the
          // circles above still jump straight there. In its old spot, a
          // compact "available for" card instead: restaurant owners,
          // hotel owners, and individuals after a private workshop, each
          // tappable straight through to that category on Services.
          const SizedBox(height: 56),
          OwnerIntroCard(
            isMobile: widget.isMobile,
            onViewProfile: _scrollToProfile,
            onAudienceTap: widget.onServiceCategoryTap,
          ),
          const SizedBox(height: 40),
          // Title + subtitle live right above the shop grid now — the
          // heading for the products themselves, not the page overall.
          // The whole thing — heading plus every product section below it
          // (categories, best sellers) — sits inside one shared card now,
          // so "the collection" visually contains the products rather than
          // the heading floating separately above a full-width grid.
          Padding(
            key: _collectionKey,
            padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 40),
            child: RevealOnScroll(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: widget.isMobile ? 24 : 36,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceRaised.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: context.colors.cream.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 32),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: SectionHeading(
                          eyebrow: context.strings.collectionEyebrow,
                          title: context.strings.collectionTitle,
                          subtitle: context.strings.collectionSubtitle,
                          titleSize: widget.isMobile ? 28 : 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (_activeCategory != null)
                      // A category circle is selected: just show that
                      // category's products, full width, no extra headings
                      // needed since the circle itself already shows which
                      // one is active.
                      ProductGrid(products: filtered, onProductTap: _openProduct)
                    else ...[
                      // Nothing selected: instead of one mixed grid, each
                      // category gets its own labelled section — plus a
                      // "Best sellers" section at the end, built from real
                      // sales_count totals (see Product model /
                      // OrdersRepository), when at least one product has
                      // actually sold.
                      for (var i = 0; i < categories.length; i++) ...[
                        _ProductSection(
                          isMobile: widget.isMobile,
                          eyebrow: null,
                          title: categories[i],
                          products: widget.products.where((p) => p.category == categories[i]).toList(),
                          onProductTap: _openProduct,
                        ),
                        const SizedBox(height: 48),
                      ],
                      if (bestSellers.isNotEmpty)
                        _ProductSection(
                          isMobile: widget.isMobile,
                          eyebrow: context.strings.bestSellersEyebrow,
                          title: context.strings.bestSellersTitle,
                          products: bestSellers,
                          onProductTap: _openProduct,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),
          WhoAmIScreen(key: _whoAmIKey, isMobile: widget.isMobile, embedded: true),
          const SizedBox(height: 60),
          _Footer(isMobile: widget.isMobile, onAdminReturn: widget.onAdminReturn),
        ],
      ),
    );
  }
}

/// One labelled block of products — either "Best sellers" (with an eyebrow
/// line above the title) or a single category's own products (just the
/// category name as the heading, no eyebrow, since it's one of several in
/// a row rather than a standalone section).
class _ProductSection extends StatelessWidget {
  final bool isMobile;
  final String? eyebrow;
  final String title;
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const _ProductSection({
    required this.isMobile,
    required this.eyebrow,
    required this.title,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: RevealOnScroll(
              child: eyebrow != null
                  ? SectionHeading(
                      eyebrow: eyebrow!,
                      title: title,
                      titleSize: isMobile ? 24 : 30,
                    )
                  : Text(
                      title,
                      style: AppFonts.display(color: context.colors.cream, size: isMobile ? 20 : 25, weight: FontWeight.w700, text: title),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        ProductGrid(products: products, onProductTap: onProductTap),
      ],
    );
  }
}

class _Hero extends StatefulWidget {
  final bool isMobile;
  final List<HomeBanner> banners;
  final VoidCallback onShopTap;
  const _Hero({required this.isMobile, required this.banners, required this.onShopTap});

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
    // "Full laptop screen" for desktop, scaled down proportionally on
    // phones so it still fits comfortably above the fold there — driven
    // off the actual viewport height rather than a fixed pixel number so
    // it adapts to whatever screen it's opened on.
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = isMobile
        ? (screenHeight * 0.55).clamp(360.0, 640.0)
        : (screenHeight * 0.92).clamp(560.0, 980.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Both the wordmark and the "NOTEBOOKS & CALENDARS" eyebrow line
          // are gone now — the sliders are the very first thing in the
          // hero, sized to fill (almost) the whole screen like a proper
          // full-bleed hero banner, with the dots directly underneath them.
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
          const SizedBox(height: 24),
          // Same pill-button treatment as OwnerIntroCard's "View full
          // profile" CTA, reused here so the hero's own call-to-action
          // matches the rest of the storefront's visual language. Sits
          // outside the banners.isNotEmpty block above so it still shows
          // even before banners have loaded in.
          GestureDetector(
            onTap: widget.onShopTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: context.colors.violetGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.violetPop.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.strings.shopTheCollection,
                    style: AppFonts.label(size: 13, color: Colors.white, letterSpacing: 0.6)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCircles extends StatefulWidget {
  final List<Product> products;
  final List<String> categories;
  final Map<String, String> categoryImages;
  // Owner-set thumbnails for the 3 fixed service circles, keyed by their
  // index in kServiceCategories. Missing/blank entries fall back to that
  // category's icon.
  final Map<int, String> serviceCategoryImages;
  final String? active;
  final bool isMobile;
  final ValueChanged<String?> onSelect;
  // Lets the service circles appended after the shop's own category
  // circles (same row — see build() below) jump to the standalone
  // Services tab and land on that specific category there.
  final ValueChanged<int> onServiceCategoryTap;

  const _CategoryCircles({
    required this.products,
    required this.categories,
    required this.categoryImages,
    required this.serviceCategoryImages,
    required this.active,
    required this.isMobile,
    required this.onSelect,
    required this.onServiceCategoryTap,
  });

  @override
  State<_CategoryCircles> createState() => _CategoryCirclesState();
}

class _CategoryCirclesState extends State<_CategoryCircles> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  double get _diameter => widget.isMobile ? 128.0 : 176.0;
  // One "step" = one circle's full footprint (circle + its side padding +
  // the separator that follows it) — advancing by exactly this much keeps
  // every auto-scroll tick landing neatly on the start of the next circle
  // instead of stopping mid-item.
  double get _step => _diameter + 16 + 48;

  @override
  void initState() {
    super.initState();
    // Auto-advances the row every 10 seconds, looping back to the start
    // once it reaches the end — so it never fights a manual swipe (a
    // mid-flight timer tick just re-targets smoothly).
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _autoAdvance());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _autoAdvance() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;
    final next = _scrollController.offset + _step;
    final target = next >= maxExtent ? 0.0 : next;
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOutCubic,
    );
  }

  /// The owner's chosen thumbnail for this category, if they set one from
  /// the dashboard; otherwise falls back to the first in-stock product's
  /// image for that category, then to no image at all.
  String? _thumbFor(String category) {
    final ownerImage = widget.categoryImages[category];
    if (ownerImage != null && ownerImage.isNotEmpty) return ownerImage;
    final inCategory = widget.products.where((p) => p.category == category);
    if (inCategory.isEmpty) return null;
    final withImage = inCategory.firstWhere(
      (p) => p.imageUrl.isNotEmpty,
      orElse: () => inCategory.first,
    );
    return withImage.imageUrl.isNotEmpty ? withImage.imageUrl : null;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageController>().isArabic;
    final diameter = _diameter;
    final rowHeight = diameter + 56;
    final items = <Widget>[
      // No "All" circle anymore — tapping the already-active category
      // deselects it instead, which shows every category again.
      ...widget.categories.map(
        (c) => _CategoryCircle(
          label: c,
          imageUrl: _thumbFor(c),
          diameter: diameter,
          selected: widget.active == c,
          onTap: () => widget.onSelect(widget.active == c ? null : c),
        ),
      ),
      // Service circles ride right along in the same row as the shop's
      // own categories — same size, same styling — just with a fixed
      // "selected" (bright) look since tapping one navigates rather than
      // filters. Each jumps down to that category in the embedded
      // Services section further down this same page.
      for (var i = 0; i < kServiceCategories.length; i++)
        _CategoryCircle(
          label: kServiceCategories[i].title.t(isArabic),
          imageUrl: widget.serviceCategoryImages[i],
          icon: kServiceCategories[i].icon,
          diameter: diameter,
          selected: true,
          onTap: () => widget.onServiceCategoryTap(i),
        ),
    ];

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => _CategoryDivider(height: rowHeight),
        itemBuilder: (context, i) => items[i],
      ),
    );
  }
}

/// Small ornamental divider dropped between each category circle: a thin
/// vertical line broken by a dot at the circle's vertical center — the
/// same "line — dot — line" motif used for section eyebrows elsewhere in
/// the app, just turned on its side to fit a horizontal row.
class _CategoryDivider extends StatelessWidget {
  final double height;
  const _CategoryDivider({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 1.5, height: 22, color: context.colors.orchid.withOpacity(0.3)),
            const SizedBox(height: 6),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: context.colors.violetGradient,
              ),
            ),
            const SizedBox(height: 6),
            Container(width: 1.5, height: 22, color: context.colors.orchid.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCircle extends StatefulWidget {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final double diameter;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCircle({
    required this.label,
    this.imageUrl,
    this.icon,
    required this.diameter,
    required this.selected,
    required this.onTap,
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
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: context.colors.violetGradient,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.surface,
                      border: Border.all(color: context.colors.bgDeep, width: 3),
                    ),
                    child: ClipOval(
                      child: Opacity(
                        opacity: selected ? 1 : 0.6,
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
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFonts.label(
                  size: 13,
                  color: selected ? context.colors.cream : context.colors.creamDim,
                  letterSpacing: 0.6,
                  text: widget.label,
                ).copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60, vertical: 32),
      color: context.colors.surface.withOpacity(0.5),
      child: Column(
        children: [
          // Plain solid color — see shop_nav_bar.dart / shimmer_text.dart
          // for why ShaderMask was dropped here (it wasn't painting).
          Text("Aya's Graphique",
              style: AppFonts.display(size: 22, weight: FontWeight.w800, color: context.colors.cream)),
          const SizedBox(height: 10),
          Text(
            context.strings.footerTagline,
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
