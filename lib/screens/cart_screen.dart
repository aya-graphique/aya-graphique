import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import '../widgets/section_heading.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onBrowse;
  const CartScreen({super.key, required this.isMobile, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 60, isMobile ? 120 : 150, isMobile ? 20 : 60, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(eyebrow: context.strings.cartEyebrow, title: context.strings.cartTitle),
          const SizedBox(height: 28),
          if (cart.lines.isEmpty)
            _EmptyCart(onBrowse: onBrowse)
          else
            isMobile
                ? Column(
                    children: [
                      ..._buildLines(cart),
                      const SizedBox(height: 24),
                      _Summary(cart: cart),
                    ],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: Column(children: _buildLines(cart))),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _Summary(cart: cart)),
                      ],
                    ),
                  ),
        ],
      ),
    );
  }

  List<Widget> _buildLines(CartProvider cart) {
    return cart.lines
        .map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CartLineTile(line: line),
            ))
        .toList();
  }
}

class _CartLineTile extends StatelessWidget {
  final CartLine line;
  const _CartLineTile({required this.line});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = line.product;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: context.colors.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: context.colors.surfaceRaised,
                      child: Icon(Icons.menu_book_rounded, color: context.colors.creamDim),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.display(
                            color: context.colors.cream, size: 16, weight: FontWeight.w700, text: product.name)),
                    const SizedBox(height: 4),
                    product.hasDiscount
                        ? Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Text(formatPrice(product.discountedPrice),
                                  style: AppFonts.body(size: 13.5, color: context.colors.orchidSoft)),
                              Text(
                                formatPrice(product.price),
                                style: AppFonts.body(size: 11.5, color: context.colors.creamDim)
                                    .copyWith(decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          )
                        : Text(formatPrice(product.price),
                            style: AppFonts.body(size: 13.5, color: context.colors.orchidSoft)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, size: 18, color: context.colors.creamDim),
                onPressed: () => cart.remove(product.id),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepButton(context, Icons.remove_rounded, () => cart.setQuantity(product.id, line.quantity - 1)),
                SizedBox(
                  width: 26,
                  child: Text('${line.quantity}',
                      textAlign: TextAlign.center,
                      style: AppFonts.body(size: 14, weight: FontWeight.w700, color: context.colors.cream)),
                ),
                _stepButton(context, Icons.add_rounded, () => cart.setQuantity(product.id, line.quantity + 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: context.colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 14, color: context.colors.creamDim),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final CartProvider cart;
  const _Summary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: context.colors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.strings.orderSummary, style: AppFonts.display(color: context.colors.cream, size: 18, weight: FontWeight.w700)),
          const SizedBox(height: 18),
          _row(context, context.strings.subtotal, formatPrice(cart.subtotal)),
          const SizedBox(height: 8),
          _row(context, context.strings.shipping, formatPrice(cart.shipping)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: context.colors.border(0.12), height: 1),
          ),
          _row(context, context.strings.total, formatPrice(cart.total), emphasize: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: context.colors.violetGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    context.strings.proceedToCheckout,
                    style: AppFonts.label(size: 13.5, color: Colors.white, letterSpacing: 1.2)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool emphasize = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppFonts.body(color: context.colors.creamDim, size: emphasize ? 15 : 14)),
        Text(
          value,
          style: emphasize
              ? AppFonts.display(size: 18, weight: FontWeight.w700, color: context.colors.orchidSoft)
              : AppFonts.body(size: 14, weight: FontWeight.w600, color: context.colors.cream),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 56, color: context.colors.creamDim),
          const SizedBox(height: 16),
          Text(context.strings.emptyCartTitle, style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(context.strings.emptyCartSubtitle,
              style: AppFonts.body(color: context.colors.creamDim, size: 14)),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: onBrowse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              decoration: BoxDecoration(
                gradient: context.colors.violetGradient,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                context.strings.browseNotebooks,
                style: AppFonts.label(size: 13, color: Colors.white, letterSpacing: 1.2)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
