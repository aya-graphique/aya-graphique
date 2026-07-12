import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import 'tilt_3d_card.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tilt3DCard(
      maxTiltDegrees: 6,
      liftOnHover: 6,
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(gradient: context.colors.cardGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    // .cover fills the entire card area with no empty
                    // gaps on the sides/top/bottom, cropping slightly
                    // if the photo's proportions don't exactly match the
                    // card's aspect ratio.
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: context.colors.surfaceRaised);
                    },
                    errorBuilder: (context, error, stack) => Container(
                      color: context.colors.surfaceRaised,
                      child: Icon(Icons.menu_book_rounded,
                          color: context.colors.creamDim, size: 40),
                    ),
                  ),
                  if (!product.inStock)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _Pill(text: context.strings.soldOut, color: context.colors.danger),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: AppFonts.label(
                      color: context.colors.orchid,
                      size: 10.5,
                      letterSpacing: 1.6,
                      text: product.category,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.display(
                      color: context.colors.cream,
                      size: 16.5,
                      weight: FontWeight.w700,
                      text: product.name,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatPrice(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            size: 15,
                            weight: FontWeight.w700,
                            color: context.colors.orchidSoft,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AddToCartButton(product: product),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final Product product;
  const _AddToCartButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: product.inStock
            ? () {
                cart.add(product);
                final colors = context.colorsRead;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1100),
                    backgroundColor: colors.surfaceRaised,
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      context.strings.addedToCart(product.name),
                      style: AppFonts.body(size: 13, color: colors.cream),
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: product.inStock ? context.colors.violetGradient : null,
            color: product.inStock ? null : context.colors.surfaceRaised,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppFonts.label(size: 9.5, color: Colors.white, letterSpacing: 1.2),
      ),
    );
  }
}
