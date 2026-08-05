import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';
import 'product_card.dart';
import 'reveal_on_scroll.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  /// When true, tablet/desktop widths get a single horizontally-swipeable
  /// row (drag with mouse, trackpad, or touch) instead of the multi-row
  /// grid. Mobile is unaffected either way — it already gets the
  /// one-card-at-a-time [_ProductSwiper] below. Opt-in per call site (the
  /// Shop tab uses this; Home's preview, Search, and Favorites keep the
  /// regular grid).
  final bool singleRowOnDesktop;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.singleRowOnDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);

    // Mobile no longer gets a stacked single-column grid — it gets a
    // horizontally-swipeable "one card at a time" carousel instead, with
    // a peek of the next/previous card to hint that swiping moves you
    // through the whole shop.
    if (isMobile) {
      return _ProductSwiper(products: products, onProductTap: onProductTap);
    }

    if (singleRowOnDesktop) {
      return _ProductRow(products: products, onProductTap: onProductTap);
    }

    final columns = AppBreakpoints.isTablet(width) ? 3 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, i) {
        final product = products[i];
        return RevealOnScroll(
          delay: Duration(milliseconds: 40 * (i % columns)),
          child: ProductCard(
            product: product,
            onTap: () => onProductTap(product),
          ),
        );
      },
    );
  }
}

/// Flutter's default web scroll behaviour only lets touch/stylus pointers
/// drag a scrollable — a mouse click-and-drag is ignored. This lets touch,
/// mouse, trackpad, and stylus all drag the row, so desktop visitors can
/// swipe it with a mouse the same way a phone visitor would with a finger.
class _DraggableScrollBehavior extends MaterialScrollBehavior {
  const _DraggableScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// The tablet/desktop "single row" layout: every product in one
/// horizontally-swipeable row instead of wrapping into multiple rows.
/// Card width is computed the exact same way the old grid computed it
/// (same column count, same gaps) so switching to this row doesn't
/// change how big the cards look — it only changes wrapping into
/// swiping once there are more products than fit on screen.
class _ProductRow extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const _ProductRow({required this.products, required this.onProductTap});

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  final ScrollController _controller = ScrollController();
  // Same idea as the mobile swiper's hint: shown until the visitor
  // actually drags the row once, then gone for good on this screen.
  bool _dismissedHint = false;

  static const double _cardAspectRatio = 0.62;
  static const double _spacing = 20;
  static const double _horizontalPadding = 24;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!_dismissedHint && _controller.offset.abs() > 4) {
        setState(() => _dismissedHint = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final columns = AppBreakpoints.isTablet(width) ? 3 : 4;
    // Only worth teaching people to drag if there's actually more product
    // than fits on screen at once.
    final needsScroll = widget.products.length > columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Same formula GridView.builder's SliverGridDelegateWithFixedCrossAxisCount
        // used to size each cell: total width minus the outer padding and
        // the gaps between columns, split evenly across the columns.
        final available = constraints.maxWidth - (_horizontalPadding * 2) - (_spacing * (columns - 1));
        final cardWidth = available / columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (needsScroll) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: _dismissedHint ? 0 : 1,
                  child: const _SwipeHint(),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              height: cardWidth / _cardAspectRatio,
              child: ScrollConfiguration(
                behavior: const _DraggableScrollBehavior(),
                child: ListView.builder(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                  itemCount: widget.products.length,
                  itemBuilder: (context, i) {
                    final product = widget.products[i];
                    return Padding(
                      padding: EdgeInsetsDirectional.only(end: i == widget.products.length - 1 ? 0 : _spacing),
                      child: SizedBox(
                        width: cardWidth,
                        child: RevealOnScroll(
                          delay: Duration(milliseconds: 40 * i.clamp(0, 6)),
                          child: ProductCard(
                            product: product,
                            onTap: () => widget.onProductTap(product),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The mobile replacement for the grid: one product card centred per
/// "page", swiped between horizontally. Respects the ambient text
/// direction automatically (Flutter's [PageView] flips its scroll axis
/// for RTL locales on its own), so in Arabic swiping right moves to the
/// *next* product, matching the rest of the RTL layout.
class _ProductSwiper extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const _ProductSwiper({required this.products, required this.onProductTap});

  @override
  State<_ProductSwiper> createState() => _ProductSwiperState();
}

class _ProductSwiperState extends State<_ProductSwiper> {
  late final PageController _controller;
  double _page = 0;
  // The "swipe to see products" hint stays up until the shopper actually
  // swipes once, then fades away for good — it's only there to teach
  // first-time visitors the cards are draggable, not to nag afterwards.
  bool _dismissedHint = false;

  // How much of the viewport each card takes up — leaves a sliver of the
  // neighbouring cards peeking in on both sides. Smaller than before so
  // the card itself reads as more compact on screen.
  static const double _viewportFraction = 0.86;
  // Width / height. Taller than before so the image area (the card's
  // remaining height above the fixed-height text footer) is bigger —
  // ProductCard renders the photo with BoxFit.contain, which always shows
  // the whole image, and now it has more room to display large instead of
  // looking small/letterboxed inside the card.
  static const double _cardAspectRatio = 0.60;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
    _controller.addListener(() {
      if (_controller.hasClients && _controller.page != null) {
        final newPage = _controller.page!;
        // Any noticeable movement away from the very first card counts as
        // "they found it" — dismiss the hint for the rest of this screen's
        // lifetime.
        final justDismissed = !_dismissedHint && (newPage - _page).abs() > 0.03;
        setState(() {
          _page = newPage;
          if (justDismissed) _dismissedHint = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * _viewportFraction;
        final cardHeight = cardWidth / _cardAspectRatio;

        return Column(
          children: [
            if (widget.products.length > 1) ...[
              AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: _dismissedHint ? 0 : 1,
                child: const _SwipeHint(),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.products.length,
                itemBuilder: (context, i) {
                  final product = widget.products[i];
                  // Distance from the centred page, used to gently
                  // shrink/fade neighbours so the active card pops.
                  final distance = (_page - i).abs().clamp(0.0, 1.0);
                  final scale = 1 - (distance * 0.12);
                  final opacity = 1 - (distance * 0.35);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: ProductCard(
                          product: product,
                          onTap: () => widget.onProductTap(product),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.products.length > 1) ...[
              const SizedBox(height: 16),
              _PageDots(count: widget.products.length, page: _page),
            ],
          ],
        );
      },
    );
  }
}

/// A small pill above the product cards that gently rocks side to side —
/// a quiet nudge telling first-time mobile visitors the cards are
/// swipeable, not a static stack. Fades away the moment they swipe once
/// (see [_ProductSwiperState._dismissedHint]).
class _SwipeHint extends StatefulWidget {
  const _SwipeHint();

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _shift = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hint = context.strings.swipeProductsHint;

    return AnimatedBuilder(
      animation: _shift,
      builder: (context, child) => Transform.translate(offset: Offset(_shift.value, 0), child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: context.colors.orchidSoft.withOpacity(0.14),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: context.colors.orchidSoft.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swipe_rounded, size: 15, color: context.colors.orchidSoft),
            const SizedBox(width: 6),
            Text(
              hint,
              style: AppFonts.label(
                color: context.colors.creamDim,
                size: 12,
                weight: FontWeight.w600,
                letterSpacing: 0.4,
                text: hint,
                boostArabicSize: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small dot-row page indicator; the active dot stretches into a pill.
/// Long categories fall back to a compact "x / N" label instead of a
/// dozens-of-dots row.
class _PageDots extends StatelessWidget {
  final int count;
  final double page;

  const _PageDots({required this.count, required this.page});

  @override
  Widget build(BuildContext context) {
    const maxDots = 8;
    final current = page.round().clamp(0, count - 1);

    if (count > maxDots) {
      final label = '${current + 1} / $count';
      return Text(
        label,
        style: AppFonts.label(
          color: context.colors.creamDim,
          size: 13,
          text: label,
          boostArabicSize: false,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = current == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 9,
          height: 9,
          decoration: BoxDecoration(
            color: active
                ? context.colors.orchidSoft
                : context.colors.creamDim.withOpacity(0.3),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
