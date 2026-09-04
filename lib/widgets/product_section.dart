import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_grid.dart';
import 'reveal_on_scroll.dart';
import 'section_heading.dart';

/// One labelled block of products — either "Best sellers" (with an eyebrow
/// line above the title) or a single category's own products (just the
/// category name as the heading, no eyebrow, since it's normally one of
/// several stacked one after another).
///
/// Shared between ShopScreen (the standalone Shop tab) and Home's shop
/// preview, so a category heading looks and reads identically wherever
/// products are grouped by category.
class ProductSection extends StatelessWidget {
  final bool isMobile;
  final String? eyebrow;
  final String title;
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const ProductSection({
    super.key,
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
                      titleSize: isMobile ? 20 : 24,
                    )
                  : Text(
                      title,
                      style: AppFonts.display(
                        color: context.colors.cream,
                        size: AppFonts.isArabic(title)
                            ? (isMobile ? 18 : 22)
                            : (isMobile ? 30 : 38),
                        weight: FontWeight.w700,
                        text: title,
                        boostArabicSize: false,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        ProductGrid(products: products, onProductTap: onProductTap, singleRowOnDesktop: true),
      ],
    );
  }
}
