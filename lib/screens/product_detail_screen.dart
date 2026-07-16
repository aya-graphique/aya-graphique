import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/tilt_3d_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    final cart = context.read<CartProvider>();
    AppFonts.forceArabic = context.watch<FontController>().arabicMode;

    return Directionality(
      textDirection: context.watch<LanguageController>().textDirection,
      child: Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: AnimatedBackdrop(
        intensity: 0.5,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    _CartHeaderBadge(onTap: () => Navigator.of(context).pop()),
                  ],
                ),
                const SizedBox(height: 24),
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Gallery(product: product, isMobile: isMobile),
                          const SizedBox(height: 28),
                          _Details(
                            product: product,
                            quantity: _quantity,
                            onQuantityChanged: (q) => setState(() => _quantity = q),
                            onAddToCart: () => _addToCart(context, cart, product),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: _Gallery(product: product, isMobile: isMobile)),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 4,
                            child: _Details(
                              product: product,
                              quantity: _quantity,
                              onQuantityChanged: (q) => setState(() => _quantity = q),
                              onAddToCart: () => _addToCart(context, cart, product),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  void _addToCart(BuildContext context, CartProvider cart, Product product) {
    cart.add(product, quantity: _quantity);
    final colors = context.colorsRead;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 2200),
          backgroundColor: colors.surfaceRaised,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: colors.orchid.withOpacity(0.5), width: 1),
          ),
          content: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: colors.violetGradient,
                ),
                child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.strings.addedQtyToCart(_quantity, product.name),
                  style: AppFonts.body(size: 13, color: colors.cream),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _Gallery extends StatelessWidget {
  final Product product;
  final bool isMobile;
  const _Gallery({required this.product, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Tilt3DCard(
      maxTiltDegrees: 5,
      liftOnHover: 0,
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: isMobile ? 0.82 : 0.78,
        child: Container(
          decoration: BoxDecoration(gradient: context.colors.cardGradient),
          child: Image.network(
            product.imageUrl,
            // .contain so the full product photo is always visible,
            // uncropped — .cover was slicing off part of the image
            // whenever its proportions didn't match this fixed
            // aspect-ratio frame.
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => Center(
              child: Icon(Icons.menu_book_rounded, color: context.colors.creamDim, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const _Details({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.category.toUpperCase(),
            style: AppFonts.label(color: context.colors.orchid, text: product.category)),
        const SizedBox(height: 12),
        Text(product.name,
            style: AppFonts.display(color: context.colors.cream, size: 34, height: 1.08, text: product.name)),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 18, color: context.colors.orchid),
            const SizedBox(width: 4),
            Text('${product.rating}', style: AppFonts.body(color: context.colors.creamDim, size: 14, weight: FontWeight.w600)),
            const SizedBox(width: 14),
            Text(
              product.inStock ? context.strings.inStock : context.strings.soldOut,
              style: AppFonts.body(
                size: 13,
                color: product.inStock ? context.colors.success : context.colors.danger,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              formatPrice(product.discountedPrice),
              style: AppFonts.display(size: 26, weight: FontWeight.w700, color: context.colors.orchidSoft),
            ),
            if (product.hasDiscount) ...[
              const SizedBox(width: 12),
              Text(
                formatPrice(product.price),
                style: AppFonts.body(size: 16, color: context.colors.creamDim)
                    .copyWith(decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.success.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '-${product.discountPercent.truncateToDouble() == product.discountPercent ? product.discountPercent.toStringAsFixed(0) : product.discountPercent.toStringAsFixed(1)}%',
                  style: AppFonts.label(size: 11, color: Colors.white, letterSpacing: 0.5),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),
        Text(product.description,
            style: AppFonts.body(color: context.colors.creamDim, size: 15.5, text: product.description)),
        if (product.tags.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: context.colors.border(0.08)),
                      ),
                      child: Text('#$t',
                          style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 0.5, text: t)),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          children: [
            _QuantityStepper(quantity: quantity, onChanged: onQuantityChanged),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: product.inStock ? onAddToCart : null,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: product.inStock ? context.colors.violetGradient : null,
                    color: product.inStock ? null : context.colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Text(
                      product.inStock ? context.strings.addToCart : context.strings.soldOut,
                      style: AppFonts.label(
                        size: 13.5,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  const _QuantityStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: context.colors.border(0.08)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove_rounded, size: 18, color: context.colors.creamDim),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppFonts.body(size: 15, weight: FontWeight.w700, color: context.colors.cream),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_rounded, size: 18, color: context.colors.creamDim),
            onPressed: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _CartHeaderBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _CartHeaderBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().itemCount;
    return Material(
      color: context.colors.surface.withOpacity(0.7),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.shopping_bag_rounded, size: 20, color: context.colors.cream),
              if (count > 0)
                Positioned(
                  top: -6,
                  right: -8,
                  child: AnimatedScale(
                    scale: 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: Container(
                      key: ValueKey(count),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: context.colors.violetGradient,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: AppFonts.label(size: 10.5, weight: FontWeight.w700, color: Colors.white, letterSpacing: 0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface.withOpacity(0.7),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: color ?? context.colors.cream),
        ),
      ),
    );
  }
}
