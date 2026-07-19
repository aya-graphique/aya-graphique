import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/checkout_screen.dart';
import '../services/products_repository.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';

/// Opens a small "mini cart" panel right after the shopper taps + / Add to
/// cart, showing everything currently in the cart plus a button straight
/// to checkout — so they don't have to leave the product page/grid to see
/// what's in their cart or to check out.
///
/// Safe to call from event handlers (doesn't rely on `context.strings`'
/// `watch`), and reflects live cart changes (quantity +/-, remove) while
/// it's open, since it listens to [CartProvider] itself.
Future<void> showMiniCartSheet(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 720;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.55),
    builder: (sheetContext) => _MiniCartSheet(isMobile: isMobile),
  );
}

class _MiniCartSheet extends StatelessWidget {
  final bool isMobile;
  const _MiniCartSheet({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.stringsRead;
    final cart = context.watch<CartProvider>();

    return Align(
      alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 24, vertical: isMobile ? 0 : 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 620, maxHeight: MediaQuery.of(context).size.height * 0.92),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(24),
                  bottom: isMobile ? Radius.zero : const Radius.circular(24),
                ),
                border: Border.all(color: colors.border(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 14, 6),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_bag_rounded, color: colors.orchid, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            strings.cartTitle,
                            style: AppFonts.display(color: colors.cream, size: 23, weight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: colors.creamDim),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: cart.lines.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              strings.emptyCartTitle,
                              style: AppFonts.body(color: colors.creamDim, size: 15),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Column(
                              children: [
                                for (int i = 0; i < cart.lines.length; i++) ...[
                                  if (i > 0) const SizedBox(height: 12),
                                  _MiniCartLine(line: cart.lines[i]),
                                ],
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(2, 14, 2, 0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_shipping_outlined, size: 15, color: colors.creamDim),
                                      const SizedBox(width: 6),
                                      Text(
                                        strings.estimatedDelivery,
                                        style: AppFonts.body(size: 12.5, color: colors.creamDim),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (cart.lines.isNotEmpty) ...[
                    _SuggestedProducts(cartProductIds: cart.lines.map((l) => l.product.id).toSet()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Container(height: 1, color: colors.border(0.1)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Column(
                        children: [
                          _row(context, strings.subtotal, formatPrice(cart.subtotal)),
                          const SizedBox(height: 8),
                          _row(context, strings.shipping, formatPrice(cart.shipping)),
                          const SizedBox(height: 12),
                          _row(context, strings.total, formatPrice(cart.total), emphasize: true),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                            );
                          },
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: colors.violetPop,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                strings.proceedToCheckout,
                                style: AppFonts.label(size: 15, color: Colors.white, letterSpacing: 1.0)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(
                          strings.continueShopping,
                          style: AppFonts.label(size: 13.5, color: colors.creamDim, letterSpacing: 0.4),
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value, {bool emphasize = false}) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppFonts.body(color: colors.creamDim, size: emphasize ? 16 : 15)),
        Text(
          value,
          style: emphasize
              ? AppFonts.display(size: 19, weight: FontWeight.w700, color: colors.orchidSoft)
              : AppFonts.body(size: 15, weight: FontWeight.w600, color: colors.cream),
        ),
      ],
    );
  }
}

class _MiniCartLine extends StatelessWidget {
  final CartLine line;
  const _MiniCartLine({required this.line});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cart = context.read<CartProvider>();
    final product = line.product;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceRaised.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border(0.06)),
      ),
      child: IntrinsicHeight(
        child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 84,
              height: 84,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: colors.surfaceRaised,
                  child: Icon(Icons.menu_book_rounded, color: colors.creamDim, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.display(color: colors.cream, size: 15, weight: FontWeight.w700, text: product.name),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(formatPrice(product.discountedPrice), style: AppFonts.body(size: 13.5, color: colors.orchidSoft)),
                    const SizedBox(width: 8),
                    Icon(Icons.star_rounded, size: 14, color: colors.orchid),
                    const SizedBox(width: 2),
                    Text(
                      '${product.rating}',
                      style: AppFonts.body(size: 12.5, color: colors.creamDim, weight: FontWeight.w600),
                    ),
                  ],
                ),
                if (product.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(size: 12, color: colors.creamDim.withOpacity(0.85)),
                  ),
                ],
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => cart.remove(product.id),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline_rounded, size: 18, color: colors.creamDim),
                  ),
                ),
              ),
              Row(
                children: [
                  _stepButton(context, Icons.remove_rounded, () => cart.setQuantity(product.id, line.quantity - 1)),
                  SizedBox(
                    width: 22,
                    child: Text('${line.quantity}',
                        textAlign: TextAlign.center,
                        style: AppFonts.body(size: 14.5, weight: FontWeight.w700, color: colors.cream)),
                  ),
                  _stepButton(context, Icons.add_rounded, () => cart.setQuantity(product.id, line.quantity + 1)),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _stepButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 12, color: colors.creamDim),
        ),
      ),
    );
  }
}

/// A horizontal "You might also like" strip beneath the cart lines —
/// pulls the catalog once, filters out whatever's already in the cart,
/// and lets the shopper add a suggestion with a single tap without
/// leaving the sheet. Renders nothing while loading or if there's simply
/// nothing else to suggest (empty catalog / everything's already in the
/// cart), so it never leaves an awkward empty gap.
class _SuggestedProducts extends StatefulWidget {
  final Set<String> cartProductIds;
  const _SuggestedProducts({required this.cartProductIds});

  @override
  State<_SuggestedProducts> createState() => _SuggestedProductsState();
}

class _SuggestedProductsState extends State<_SuggestedProducts> {
  late final Future<List<Product>> _future = ProductsRepository.fetchAll();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final strings = context.stringsRead;

    return FutureBuilder<List<Product>>(
      future: _future,
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <Product>[];
        final suggestions = all
            .where((p) => !widget.cartProductIds.contains(p.id) && p.inStock)
            .take(8)
            .toList();
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  strings.youMightAlsoLike,
                  style: AppFonts.display(color: colors.cream, size: 14.5, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 158,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => _SuggestedTile(product: suggestions[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestedTile extends StatelessWidget {
  final Product product;
  const _SuggestedTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cart = context.read<CartProvider>();

    return Container(
      width: 118,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceRaised.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 74,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: colors.surfaceRaised,
                      child: Icon(Icons.menu_book_rounded, color: colors.creamDim, size: 18),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Material(
                  color: colors.violetPop,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => cart.add(product),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.body(color: colors.cream, size: 12, weight: FontWeight.w700, text: product.name),
          ),
          const SizedBox(height: 2),
          Text(
            formatPrice(product.discountedPrice),
            style: AppFonts.body(size: 11.5, color: colors.orchidSoft),
          ),
        ],
      ),
    );
  }
}
