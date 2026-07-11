import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_grid.dart';
import '../widgets/reveal_on_scroll.dart';
import '../widgets/section_heading.dart';
import 'product_detail_screen.dart';

/// Lets other tabs (currently just Home's product category circles) jump
/// straight to the standalone Shop tab with one particular category
/// already selected — same remote-control pattern as
/// ServicesFocusController in graphical_services_screen.dart.
class ShopFocusController extends ChangeNotifier {
  String? _requestedCategory;
  String? get requestedCategory => _requestedCategory;

  void focusCategory(String category) {
    _requestedCategory = category;
    notifyListeners();
  }
}

/// The storefront's own standalone "Shop" tab — the product grid, category
/// filter, and best-sellers section that used to live inline on Home. Home
/// now just teases the collection (hero + category circles) and hands off
/// here for the actual browsing/buying.
class ShopScreen extends StatefulWidget {
  final List<Product> products;
  final bool isMobile;
  final ScrollController scrollController;
  /// Optional remote control — see [ShopFocusController].
  final ShopFocusController? focusController;

  const ShopScreen({
    super.key,
    required this.products,
    required this.isMobile,
    required this.scrollController,
    this.focusController,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String? _activeCategory;

  @override
  void initState() {
    super.initState();
    widget.focusController?.addListener(_onFocusRequest);
  }

  @override
  void dispose() {
    widget.focusController?.removeListener(_onFocusRequest);
    super.dispose();
  }

  void _onFocusRequest() {
    final requested = widget.focusController?.requestedCategory;
    if (requested == null) return;
    setState(() => _activeCategory = requested);
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
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
          // Same top offset as every other standalone tab (home, search,
          // services, cart) so switching tabs doesn't jump the content
          // under the fixed nav bar.
          SizedBox(height: widget.isMobile ? 120 : 150),
          Padding(
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
                  border: Border.all(color: context.colors.border(0.08)),
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
                    if (categories.length > 1) ...[
                      const SizedBox(height: 22),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 32),
                        child: _CategoryChips(
                          categories: categories,
                          active: _activeCategory,
                          onSelect: (c) => setState(() => _activeCategory = c),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    if (_activeCategory != null)
                      // A category chip is selected: just show that
                      // category's products, full width, no extra headings
                      // needed since the chip itself already shows which
                      // one is active.
                      ProductGrid(products: filtered, onProductTap: _openProduct)
                    else ...[
                      // Nothing selected: "Best sellers" leads the page —
                      // built from real sales_count totals, shown only when
                      // at least one product has actually sold — followed
                      // by each category in its own labelled section.
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
                        const SizedBox(height: 48),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
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

/// Simple pill-style filter row for the shop's own product categories.
/// An "All" chip always leads the row so shoppers can explicitly clear the
/// filter and see everything, same as the initial/default state.
class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? active;
  final ValueChanged<String?> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _CategoryChip(
          label: context.strings.categoryAll,
          selected: active == null,
          onTap: () => onSelect(null),
        ),
        for (final category in categories)
          _CategoryChip(
            label: category,
            selected: active == category,
            onTap: () => onSelect(category),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? context.colors.violetGradient : null,
          color: selected ? null : context.colors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : context.colors.border(0.14),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.label(
            size: 13,
            color: selected ? Colors.white : context.colors.creamDim,
            letterSpacing: 0.4,
            text: label,
          ).copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }
}
