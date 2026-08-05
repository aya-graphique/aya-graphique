import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
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
class _ProductRow extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const _ProductRow({required this.products, required this.onProductTap});

  static const double _cardAspectRatio = 0.62;
  static const double _spacing = 20;
  static const double _horizontalPadding = 24;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final columns = AppBreakpoints.isTablet(width) ? 3 : 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Same formula GridView.builder's SliverGridDelegateWithFixedCrossAxisCount
        // used to size each cell: total width minus the outer padding and
        // the gaps between columns, split evenly across the columns.
        final available = constraints.maxWidth - (_horizontalPadding * 2) - (_spacing * (columns - 1));
        final cardWidth = available / columns;

        return SizedBox(
          height: cardWidth / _cardAspectRatio,
          child: ScrollConfiguration(
            behavior: const _DraggableScrollBehavior(),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final product = products[i];
                return Padding(
                  padding: EdgeInsetsDirectional.only(end: i == products.length - 1 ? 0 : _spacing),
                  child: SizedBox(
                    width: cardWidth,
                    child: RevealOnScroll(
                      delay: Duration(milliseconds: 40 * i.clamp(0, 6)),
                      child: ProductCard(
                        product: product,
                        onTap: () => onProductTap(product),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
        setState(() => _page = _controller.page!);
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
