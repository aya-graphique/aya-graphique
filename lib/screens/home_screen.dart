import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../localization/app_strings.dart';
import '../models/home_banner.dart';
import '../models/product.dart';
import '../services/categories_repository.dart';
import '../services/home_banners_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/home_banner_slideshow.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/product_grid.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_heading.dart';
import '../widgets/shimmer_text.dart';
import 'admin/admin_login_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Product> products;
  final bool isMobile;
  final ScrollController scrollController;
  final VoidCallback? onAdminReturn;

  const HomeScreen({
    super.key,
    required this.products,
    required this.isMobile,
    required this.scrollController,
    this.onAdminReturn,
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
  List<HomeBanner> _banners = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryImages();
    _loadBanners();
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

  Future<void> _loadBanners() async {
    final banners = await HomeBannersRepository.fetchSlides();
    if (!mounted) return;
    setState(() => _banners = banners);
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
          _Hero(isMobile: widget.isMobile, onShopNow: () {
            widget.scrollController.animateTo(
              widget.isMobile ? 520 : 600,
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeInOutCubic,
            );
          }),
          const SizedBox(height: 40),
          MarqueeStrip(words: [
            context.strings.marqueeNotebooks,
            context.strings.marqueeCalendars,
            context.strings.marqueeBookmark,
            context.strings.marqueeStand,
          ]),
          if (_banners.isNotEmpty) ...[
            const SizedBox(height: 20),
            HomeBannerSlideshow(
              banners: _banners,
              height: widget.isMobile ? 190 : 340,
            ),
          ],
          const SizedBox(height: 56),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: RevealOnScroll(
                child: SectionHeading(
                  eyebrow: context.strings.collectionEyebrow,
                  title: context.strings.collectionTitle,
                  subtitle: context.strings.collectionSubtitle,
                  titleSize: widget.isMobile ? 28 : 34,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _CategoryCircles(
            products: widget.products,
            categories: categories,
            categoryImages: _categoryImages,
            active: _activeCategory,
            isMobile: widget.isMobile,
            onSelect: (c) => setState(() => _activeCategory = c),
          ),
          const SizedBox(height: 40),
          if (_activeCategory != null)
            // A category circle is selected: just show that category's
            // products, full width, no extra headings needed since the
            // circle itself already shows which one is active.
            ProductGrid(products: filtered, onProductTap: _openProduct)
          else ...[
            // Nothing selected: instead of one mixed grid, each category
            // gets its own labelled section — plus a "Best sellers" section
            // up top, built from real sales_count totals (see Product
            // model / OrdersRepository), when at least one product has
            // actually sold.
            if (bestSellers.isNotEmpty) ...[
              _ProductSection(
                isMobile: widget.isMobile,
                eyebrow: context.strings.bestSellersEyebrow,
                title: context.strings.bestSellersTitle,
                products: bestSellers,
                onProductTap: _openProduct,
              ),
              const SizedBox(height: 48),
            ],
            for (var i = 0; i < categories.length; i++) ...[
              _ProductSection(
                isMobile: widget.isMobile,
                eyebrow: null,
                title: categories[i],
                products: widget.products.where((p) => p.category == categories[i]).toList(),
                onProductTap: _openProduct,
              ),
              if (i != categories.length - 1) const SizedBox(height: 48),
            ],
          ],
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

class _Hero extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onShopNow;
  const _Hero({required this.isMobile, required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 28, height: 2, color: context.colors.orchid),
              const SizedBox(width: 10),
              Text(context.strings.heroEyebrow, style: AppFonts.label(color: context.colors.orchid, )),
              const SizedBox(width: 10),
              Container(width: 28, height: 2, color: context.colors.orchid),
            ],
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 22),
          ShimmerHeadline(
            text: "Aya's Graphique",
            textAlign: TextAlign.center,
            style: AppFonts.display(color: context.colors.cream, size: isMobile ? 36 : 76, height: 1.0),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: isMobile ? double.infinity : 560,
            child: Text(
              context.strings.heroSubtitle,
              textAlign: TextAlign.center,
              style: AppFonts.body(color: context.colors.creamDim, size: isMobile ? 15 : 17),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 150.ms),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: onShopNow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              decoration: BoxDecoration(
                gradient: context.colors.violetGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.violetPop.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Text(
                context.strings.shopTheCollection,
                style: AppFonts.label(
                  size: 14,
                  color: Colors.white,
                  letterSpacing: 1.6,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 250.ms).scaleXY(begin: 0.94, end: 1),
        ],
      ),
    );
  }
}

class _CategoryCircles extends StatefulWidget {
  final List<Product> products;
  final List<String> categories;
  final Map<String, String> categoryImages;
  final String? active;
  final bool isMobile;
  final ValueChanged<String?> onSelect;

  const _CategoryCircles({
    required this.products,
    required this.categories,
    required this.categoryImages,
    required this.active,
    required this.isMobile,
    required this.onSelect,
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
    // Auto-advances the row every 5 seconds, looping back to the start
    // once it reaches the end — so it never fights a manual swipe (a
    // mid-flight timer tick just re-targets smoothly).
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _autoAdvance());
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
    final diameter = _diameter;
    final rowHeight = diameter + 56;
    final items = <Widget>[
      _CategoryCircle(
        label: context.strings.categoryAll,
        icon: Icons.grid_view_rounded,
        diameter: diameter,
        selected: widget.active == null,
        onTap: () => widget.onSelect(null),
      ),
      ...widget.categories.map(
        (c) => _CategoryCircle(
          label: c,
          imageUrl: _thumbFor(c),
          diameter: diameter,
          selected: widget.active == c,
          onTap: () => widget.onSelect(c),
        ),
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
