import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_strings.dart';
import '../models/home_banner.dart';
import '../models/illustration_art_item.dart';
import '../models/product.dart';
import '../providers/language_controller.dart';
import '../services/categories_repository.dart';
import '../services/illustration_art_repository.dart';
import '../services/service_categories_repository.dart';
import '../services/settings_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/circle_carousel.dart';
import '../widgets/facebook_reviews_button.dart';
import '../widgets/home_banner_slideshow.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/owner_intro_card.dart';
import '../widgets/product_grid.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_heading.dart';
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
  // Same idea as bannersFuture, but for the second, independent banner
  // strip further down the page, right above "MOST ORDERED" — its own
  // owner-managed set of photos (see HomeBannerPlacement.mostOrdered in
  // the admin dashboard), not just a repeat of the top one.
  final Future<List<HomeBanner>> mostOrderedBannersFuture;
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
    required this.mostOrderedBannersFuture,
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
  // Owner's WhatsApp number for the "Contact now!" button right under
  // "Available for" — same source SettingsRepository feeds the Services
  // booking buttons and Checkout from.
  String _ownerWhatsapp = '';

  @override
  void initState() {
    super.initState();
    _loadCategoryImages();
    _loadServiceCategoryImages();
    _illustrationArtFuture = IllustrationArtRepository.fetchAll();
    _loadOwnerWhatsapp();
  }

  Future<void> _loadOwnerWhatsapp() async {
    final number = await SettingsRepository.fetchOwnerWhatsapp();
    if (!mounted) return;
    setState(() => _ownerWhatsapp = number);
  }

  Future<void> _openWhatsApp() async {
    if (_ownerWhatsapp.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.stringsRead.servicesWhatsappNotSet)));
      return;
    }
    final uri = Uri.parse('https://wa.me/$_ownerWhatsapp');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.stringsRead.couldntOpenWhatsApp('launchUrl returned false'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.stringsRead.couldntOpenWhatsApp('$e'))));
    }
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
            pixelsPerSecond: 20,
            words: [
              context.strings.marqueeNotebooks,
              context.strings.marqueeCalendars,
              // context.strings.marqueeBookmark,
              // context.strings.marqueeStand,
              context.strings.marqueeDigitalArt,
              context.strings.marqueeKidsGamesPrint,
              context.strings.marqueeCommercialPrint,
              context.strings.marqueeBranding,
              context.strings.marqueeLogo,
              context.strings.marqueeAds,
              context.strings.marqueeWorkshops,
            ],
          ),
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
            // A second, independent banner slideshow — same 16:9 frame
            // and same mobile/desktop sizing as the top hero, but its
            // own set of owner-uploaded photos — right before "MOST
            // ORDERED".
            FutureBuilder<List<HomeBanner>>(
              future: widget.mostOrderedBannersFuture,
              builder: (context, snapshot) {
                final banners = snapshot.data ?? const [];
                if (banners.isEmpty) return const SizedBox.shrink();
                return _Hero(isMobile: widget.isMobile, banners: banners);
              },
            ),
            const SizedBox(height: 48),
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
          // "Available for" below it. Wrapped in Center + a max width so
          // it's guaranteed to sit exactly in the middle of the screen,
          // regardless of anything else on the page.
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.isMobile ? double.infinity : 900,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 40 : 60),
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
          const SizedBox(height: 8),
          _ContactNowButton(onTap: _openWhatsApp),
          const SizedBox(height: 16),
          Center(child: FacebookReviewsButton(isMobile: widget.isMobile)),
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
    // Mobile now keeps a small side gutter (instead of going fully
    // edge-to-edge) so the rounded corners read clearly against the
    // screen edge; desktop keeps its original, larger inset frame.
    final horizontalPadding = isMobile ? 16.0 : 60.0;
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
            ClipRRect(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 28),
              child: HomeBannerSlideshow(
                banners: banners,
                height: bannerHeight.toDouble(),
                showDots: false,
                onPageChanged: (i) => setState(() => _bannerPage = i),
              ),
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
      // Always size as if there were as many circles as the Services row
      // above (kServiceCategories.length), so these stay the same size as
      // that row no matter how many the owner adds here later.
      mobileSizeReferenceCount: kServiceCategories.length,
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
            alignment: Alignment.center,
            child: RevealOnScroll(
              child: SectionHeading(
                eyebrow: context.strings.mostRequestedEyebrow,
                title: context.strings.artisticProductsLabel,
                titleSize: isMobile ? 24 : 30,
                eyebrowSize: isMobile ? 15 : 17,
                eyebrowIcon: Icons.local_fire_department_rounded,
                align: TextAlign.center,
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
        const SizedBox(height: 40),
        MarqueeStrip(
          height: 60,
          words: [
            context.strings.marqueeCalendarsShort,
            context.strings.marqueeNotebooksShort,
            context.strings.marqueeBookmarksShort,
            context.strings.marqueeGamesShort,
          ],
        ),
        const SizedBox(height: 40),
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
  // On mobile, MobileCircleCarousel normally sizes circles off how many
  // items are *in this row* (fewer items = bigger circles). Pass a fixed
  // count here so this row's circles always size themselves as if there
  // were that many items — e.g. matching the 3-circle Services row above —
  // instead of growing/shrinking as the owner adds/removes items.
  final int? mobileSizeReferenceCount;

  const _EyebrowCirclesSection({
    required this.icon,
    required this.eyebrow,
    required this.isMobile,
    required this.specs,
    required this.desktopDiameter,
    this.mobileSizeReferenceCount,
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
            sizeReferenceCount: mobileSizeReferenceCount,
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
                  size: isMobile ? 15 : 19,
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

/// Big, unmissable "Contact now!" pill sitting right under the "Available
/// for" list (OwnerIntroCard): the same violet brand gradient/glow used on
/// the Services booking buttons, with a soft breathing glow behind it
/// (flutter_animate, repeats forever) and a slight scale-up on hover/press
/// so it reads as the one thing on the page you're meant to tap. Opens the
/// owner's WhatsApp chat directly — no pre-filled message, since this is a
/// general "let's talk" entry point rather than an order or a service
/// booking.
class _ContactNowButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ContactNowButton({required this.onTap});

  @override
  State<_ContactNowButton> createState() => _ContactNowButtonState();
}

class _ContactNowButtonState extends State<_ContactNowButton> {
  bool _hovered = false;
  bool _pressed = false;
  // Bumped on every tap so the burst ring below gets a fresh Key each
  // time — that's what makes its one-shot "expand and fade" animation
  // replay from scratch on every tap instead of only ever playing once.
  int _burstId = 0;

  void _handleTap() {
    setState(() => _burstId++);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    // The shared violetGradient starts almost black (0xFF2C1240) — fine
    // floating on the app's own dark surfaces, but heavy and stain-like
    // once it's sitting directly on the light theme's white/lavender
    // background. Light mode gets a brighter two-stop version of the
    // same brand purples instead, with no near-black stop.
    final pillGradient = isDark
        ? colors.violetGradient
        : LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [colors.violetPop, colors.orchid],
          );

    // Same idea for the breathing glow and the resting/pressed shadow:
    // both get toned down in light mode so they read as a soft lift off
    // the page rather than a dark smudge against a bright background.
    final glowOpacity = isDark ? 0.55 : 0.32;
    final shadowRestOpacity = isDark ? 0.45 : 0.28;
    final shadowPressedOpacity = isDark ? 0.75 : 0.5;

    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : (_hovered ? 1.04 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Soft breathing glow behind the pill — purely decorative,
              // loops forever, same pattern as the floating service
              // circles elsewhere on Home.
              Container(
                width: 210,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: colors.violetPop.withOpacity(glowOpacity),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 1.0, end: 1.12, duration: 1300.ms, curve: Curves.easeInOut)
                  .fadeOut(begin: glowOpacity, duration: 1300.ms, curve: Curves.easeInOut),
              // One-shot glow burst — a bright ring that snaps in and
              // rapidly expands/fades outward on every tap, layered on
              // top of the constant breathing glow so a tap always
              // reads as a distinct little flash rather than blending
              // into the ambient pulse.
              IgnorePointer(
                child: Container(
                  key: ValueKey(_burstId),
                  width: 210,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: colors.orchid, width: 2),
                  ),
                )
                    .animate()
                    .scaleXY(begin: 0.85, end: 1.55, duration: 550.ms, curve: Curves.easeOut)
                    .fadeOut(begin: 0.9, duration: 550.ms, curve: Curves.easeOut),
              ),
              // Two small sparkle accents — the same auto_awesome glyph
              // used on the eyebrow pills and marquee elsewhere — that
              // twinkle in and out on their own loop, staggered so they
              // never blink in sync. Purely playful, sits just outside
              // the pill's own footprint.
              Positioned(
                top: -13,
                left: 4,
                child: Icon(Icons.auto_awesome_rounded, size: 13, color: colors.orchid)
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 650.ms, curve: Curves.easeOut)
                    .moveY(begin: 5, end: -3, duration: 650.ms, curve: Curves.easeOut)
                    .then(delay: 900.ms)
                    .fadeOut(duration: 500.ms),
              ),
              Positioned(
                bottom: -11,
                right: 6,
                child: Icon(Icons.auto_awesome_rounded, size: 10, color: colors.orchid)
                    .animate(onPlay: (c) => c.repeat(), delay: 1100.ms)
                    .fadeIn(duration: 550.ms, curve: Curves.easeOut)
                    .moveY(begin: 5, end: -3, duration: 550.ms, curve: Curves.easeOut)
                    .then(delay: 1150.ms)
                    .fadeOut(duration: 450.ms),
              ),
              // Small pulsing "online" dot at the pill's top-right
              // corner — reads as "the owner's available", not just
              // decoration, and reuses the theme's semantic success
              // green rather than introducing a new color.
              Positioned(
                top: -2,
                right: 24,
                child: _OnlineDot(color: colors.success, ringColor: colors.surface),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                decoration: BoxDecoration(
                  gradient: pillGradient,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: colors.orchid.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      // Brightens and spreads further the instant the
                      // pill is pressed, so the glow itself responds to
                      // the tap rather than just the scale bounce.
                      color: colors.violetPop.withOpacity(_pressed ? shadowPressedOpacity : shadowRestOpacity),
                      blurRadius: _pressed ? 34 : 22,
                      spreadRadius: _pressed ? 3 : 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A gentle periodic shake instead of a static icon —
                    // gives the button a little "hey, tap me" nudge every
                    // few seconds without being distracting in between.
                    const Icon(Icons.chat_bubble_rounded, size: 19, color: Colors.white)
                        .animate(onPlay: (c) => c.repeat())
                        .shake(hz: 3, duration: 500.ms, curve: Curves.easeInOut)
                        .then(delay: 2600.ms),
                    const SizedBox(width: 10),
                    Text(
                      context.strings.contactNowLabel,
                      style: AppFonts.label(
                        size: 15,
                        color: Colors.white,
                        letterSpacing: 0.4,
                        text: context.strings.contactNowLabel,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Center(child: RevealOnScroll(child: button));
  }
}

/// The small "we're online" ping badge on the Contact Now button's corner:
/// a solid dot in the theme's semantic success green, ringed in the
/// surface color so it reads as a cutout rather than a flat sticker, with
/// a soft ring behind it that expands and fades on a loop — the same
/// "live status" cue chat apps use, just built from the brand's own
/// colors instead of introducing WhatsApp's green.
class _OnlineDot extends StatelessWidget {
  final Color color;
  final Color ringColor;
  const _OnlineDot({required this.color, required this.ringColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.55)),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.7, duration: 1100.ms, curve: Curves.easeOut)
              .fadeOut(begin: 0.5, duration: 1100.ms, curve: Curves.easeOut),
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: ringColor, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}
