import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../services/products_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_backdrop.dart';
import 'product_detail_screen.dart';

/// Route target for `/product/:id`, e.g.
/// `https://yoursite.com/#/product/<id>` (see ProductCard._shareProduct,
/// which is what builds links in this shape). Every in-app "tap a
/// product" call site pushes this same route with the [Product] already
/// in hand via `extra`, so it can skip the fetch below entirely.
///
/// When opened cold — a shared link, a bookmark, a page refresh — there's
/// no in-memory [Product] to show yet, so this fetches the full catalog
/// once and finds the matching id.
///
/// If the id doesn't match anything (product deleted, bad/stale link,
/// catalog fetch failed), it quietly sends the visitor back to the
/// storefront root instead of showing an error page.
class ProductRoutePage extends StatefulWidget {
  final String productId;
  final Product? product;

  const ProductRoutePage({super.key, required this.productId, this.product});

  @override
  State<ProductRoutePage> createState() => _ProductRoutePageState();
}

class _ProductRoutePageState extends State<ProductRoutePage> {
  late final Future<Product?> _future;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _future = product != null
        ? Future.value(product)
        : ProductsRepository.fetchAll().then((products) {
            for (final p in products) {
              if (p.id == widget.productId) return p;
            }
            return null;
          });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: context.colors.bgDeep,
            body: AnimatedBackdrop(
              child: Center(
                child: CircularProgressIndicator(color: context.colors.orchid),
              ),
            ),
          );
        }
        final product = snapshot.data;
        if (product == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/');
          });
          return const SizedBox.shrink();
        }
        return ProductDetailScreen(product: product);
      },
    );
  }
}
