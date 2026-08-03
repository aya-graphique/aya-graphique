import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';
import '../utils/currency.dart';
import 'app_toast.dart';
import 'mini_cart_sheet.dart';
import 'new_arrival_badge.dart';
import 'tilt_3d_card.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // Shares the product's name + price (and, on web, a link back to the
  // storefront) through the platform share sheet. Uses `stringsRead`
  // rather than `context.strings` since this runs from a tap callback,
  // not a build method.
  void _shareProduct(BuildContext context) {
    final strings = context.stringsRead;
    final priceText = formatPrice(product.hasDiscount ? product.discountedPrice : product.price);
    final origin = Uri.base.origin;
    final text = '${product.name} — $priceText\n$origin';
    Share.share(text, subject: product.name).catchError((_) {
      // Share sheet unavailable (e.g. some desktop browsers) — fall back
      // to just copying the link so the tap still does *something*.
      Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.shareLinkCopied)),
        );
      }
    });
  }

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
              child: LayoutBuilder(
                builder: (context, cardConstraints) => Stack(
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
                  // Save (wishlist) + share icons — physically pinned to
                  // one top corner.
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CardIconButton(
                          icon: Icons.share_rounded,
                          onTap: () => _shareProduct(context),
                        ),
                        const SizedBox(width: 8),
                        _SaveButton(product: product),
                      ],
                    ),
                  ),
                  // "New" text — pinned to the physically *opposite* top
                  // corner from the icons above, with its own width cap
                  // (and shrink-to-fit) so on a very narrow card it never
                  // grows enough to reach them.
                  if (product.isNew)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardConstraints.maxWidth * 0.55),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: NewArrivalBadge(text: context.strings.newArrivalBadge),
                        ),
                      ),
                    ),
                  // Sold-out pill sits on its own line below the top row
                  // so it never overlaps the "New" text next to it.
                  if (!product.inStock)
                    Positioned(
                      left: 10,
                      top: 46,
                      right: 88,
                      child: _Pill(text: context.strings.soldOut, color: context.colors.danger),
                    ),
                ],
                ),
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
                      size: AppFonts.isArabic(product.category) ? 13 : 26,
                      letterSpacing: 1.6,
                      text: product.category,
                      boostArabicSize: false,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Name gets the full card width on its own line so it
                  // never gets squeezed (and truncated) by the discount
                  // pill sitting next to it.
                  SizedBox(
                    height: 28,
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.display(
                        color: context.colors.cream,
                        size: AppFonts.isArabic(product.name) ? 17.8 : 38.9,
                        weight: FontWeight.w700,
                        text: product.name,
                        boostArabicSize: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Reserve this row's height on every card (discounted or
                  // not) so the footer stays the same total height either
                  // way — keeps the image area above identical across the
                  // grid instead of shrinking on discounted cards. Tall
                  // enough to fit the pill's own padding without clipping.
                  SizedBox(
                    height: 28,
                    child: product.hasDiscount
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: _Pill(
                              text:
                                  '-${product.discountPercent.truncateToDouble() == product.discountPercent ? product.discountPercent.toStringAsFixed(0) : product.discountPercent.toStringAsFixed(1)}% ${context.strings.saleBadge}',
                              color: context.colors.discount,
                              size: 11,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        // Fixed height so discounted and non-discounted
                        // cards line up with the same overall card height
                        // inside the grid, regardless of whether a second
                        // (struck-through) price line is shown.
                        child: SizedBox(
                          height: 44,
                          child: product.hasDiscount
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(formatPrice(product.discountedPrice),
                                          maxLines: 1,
                                          style: AppFonts.body(text: formatPrice(product.discountedPrice), 
                                            size: AppFonts.isArabic(formatPrice(product.discountedPrice)) ? 20.5 : 36.9,
                                            weight: FontWeight.w700,
                                            color: context.colors.orchidSoft,
                                            boostArabicSize: false,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(formatPrice(product.price),
                                          maxLines: 1,
                                          style: AppFonts.body(text: formatPrice(product.price), 
                                            size: AppFonts.isArabic(formatPrice(product.price)) ? 16.2 : 29.2,
                                            color: context.colors.creamDim,
                                            boostArabicSize: false,
                                          ).copyWith(decoration: TextDecoration.lineThrough),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(formatPrice(product.price),
                                      maxLines: 1,
                                      style: AppFonts.body(text: formatPrice(product.price), 
                                        size: 20,
                                        weight: FontWeight.w700,
                                        boostArabicSize: false,
                                        color: context.colors.orchidSoft,
                                      ),
                                    ),
                                  ),
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
                showMiniCartSheet(context);
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

/// Small frosted-glass circular button used for the share icon (and as the
/// base look for [_SaveButton]) — sits directly on top of the product
/// photo, so it needs its own translucent backdrop to stay legible against
/// any image underneath it.
class _CardIconButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CardIconButton({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.32),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6.5),
          child: Icon(icon, size: 16, color: iconColor ?? Colors.white),
        ),
      ),
    );
  }
}

/// Heart toggle for the wishlist. Reads/writes [FavoritesProvider] and
/// swaps between outline and filled so the saved state is obvious at a
/// glance without needing a label on the card itself.
class _SaveButton extends StatelessWidget {
  final Product product;
  const _SaveButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final saved = favorites.isFavorite(product.id);

    return _CardIconButton(
      icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      iconColor: saved ? context.colors.danger : Colors.white,
      onTap: () {
        context.read<FavoritesProvider>().toggle(product.id);
        final strings = context.stringsRead;
        // `saved` reflects the state *before* this tap, so if it was
        // false we just added the item (and vice versa).
        showAppToast(
          context,
          message: saved ? strings.removedFromSaved : strings.addedToSaved,
          icon: saved ? Icons.favorite_border_rounded : Icons.favorite_rounded,
          accentColor: saved ? context.colors.creamDim : context.colors.danger,
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  const _Pill({required this.text, required this.color, this.size = 9});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppFonts.label(text: text.toUpperCase(), size: size, color: Colors.white, letterSpacing: 1.2),
      ),
    );
  }
}
