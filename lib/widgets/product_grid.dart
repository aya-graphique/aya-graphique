import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_card.dart';
import 'reveal_on_scroll.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const ProductGrid({super.key, required this.products, required this.onProductTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = AppBreakpoints.isMobile(width)
        ? 2
        : AppBreakpoints.isTablet(width)
            ? 3
            : 4;

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
