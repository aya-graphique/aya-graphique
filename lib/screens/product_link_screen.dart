import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/products_repository.dart';
import '../utils/unique_route.dart';
import 'main_shell.dart';
import 'product_detail_screen.dart';

/// Landing screen for a shared product link, e.g.
/// `https://yoursite.com/#/product/<id>` (see ProductCard._shareProduct,
/// which is what builds links in this shape).
///
/// It renders the normal storefront (MainShell) underneath so there's a
/// real Home page for the back button/gesture to land on, then — as soon
/// as the catalog has loaded and the matching product is found — pushes
/// ProductDetailScreen on top of it, exactly like tapping the product from
/// the shop grid would.
///
/// If the id doesn't match anything (product deleted, bad/stale link,
/// catalog fetch failed), it just quietly stays on the storefront instead
/// of showing an error page.
class ProductLinkScreen extends StatefulWidget {
  final String productId;

  const ProductLinkScreen({super.key, required this.productId});

  @override
  State<ProductLinkScreen> createState() => _ProductLinkScreenState();
}

class _ProductLinkScreenState extends State<ProductLinkScreen> {
  @override
  void initState() {
    super.initState();
    ProductsRepository.fetchAll().then((products) {
      if (!mounted) return;
      Product? match;
      for (final p in products) {
        if (p.id == widget.productId) {
          match = p;
          break;
        }
      }
      if (match == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          settings: RouteSettings(name: uniqueRouteName('product-detail')),
          builder: (_) => ProductDetailScreen(product: match!),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const MainShell();
}
