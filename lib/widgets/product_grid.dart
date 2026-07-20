import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_card.dart';
import 'reveal_on_scroll.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  // IDs of the products that should show the 🔥 Bestseller badge. Left as a
  // plain Set (rather than computed internally from `products`) so callers
  // can rank against the *full* catalog even when this particular grid is
  // only showing a filtered/sliced subset of it — see ShopScreen and
  // HomeScreen's _ShopPreviewSection.
  final Set<String> bestSellerIds;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.bestSellerIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    final columns = isMobile
        ? 2
        : AppBreakpoints.isTablet(width)
            ? 3
            : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Tighter outer/inner gaps on mobile hand more of the screen width
      // to each card, so the product photo inside it renders bigger.
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: isMobile ? 14 : 20,
        crossAxisSpacing: isMobile ? 14 : 20,
        childAspectRatio: isMobile ? 0.54 : 0.62,
      ),
      itemBuilder: (context, i) {
        final product = products[i];
        return RevealOnScroll(
          delay: Duration(milliseconds: 40 * (i % columns)),
          child: ProductCard(
            product: product,
            onTap: () => onProductTap(product),
            isBestSeller: bestSellerIds.contains(product.id),
          ),
        );
      },
    );
  }
}
