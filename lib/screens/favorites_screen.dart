import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_grid.dart';
import '../widgets/section_heading.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Product> products;
  final bool isMobile;
  final VoidCallback onBrowse;

  const FavoritesScreen({
    super.key,
    required this.products,
    required this.isMobile,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final favProducts = products.where((p) => favorites.isFavorite(p.id)).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 60,
        isMobile ? 90 : 110,
        isMobile ? 20 : 60,
        60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(eyebrow: context.strings.favoritesEyebrow, title: context.strings.favoritesTitle),
          const SizedBox(height: 28),
          if (favProducts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.favorite_border_rounded, size: 52, color: context.colors.creamDim),
                  const SizedBox(height: 16),
                  Text(context.strings.favoritesEmptyTitle,
                      style: AppFonts.display(text: context.strings.favoritesEmptyTitle, color: context.colors.cream, size: 20, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(context.strings.favoritesEmptySubtitle,
                      style: AppFonts.body(text: context.strings.favoritesEmptySubtitle, color: context.colors.creamDim, size: 14)),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: onBrowse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: context.colors.violetGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(context.strings.favoritesBrowseCta,
                        style: AppFonts.label(text: context.strings.favoritesBrowseCta, size: 13, color: Colors.white, letterSpacing: 1.2)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ProductGrid(
              products: favProducts,
              onProductTap: (p) => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
              ),
            ),
        ],
      ),
    );
  }
}
