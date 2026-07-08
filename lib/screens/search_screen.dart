import 'package:flutter/material.dart';
import '../localization/app_strings.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/product_grid.dart';
import '../widgets/section_heading.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> products;
  final bool isMobile;

  const SearchScreen({super.key, required this.products, required this.isMobile});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.products.map((p) => p.category).toSet().toList()..sort();
    final results = widget.products.where((p) {
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase()));
      final matchesCategory = _category == null || p.category == _category;
      return matchesQuery && matchesCategory;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        widget.isMobile ? 20 : 60,
        widget.isMobile ? 120 : 150,
        widget.isMobile ? 20 : 60,
        60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(eyebrow: context.strings.searchEyebrow, title: context.strings.searchTitle),
          const SizedBox(height: 24),
          _SearchField(controller: _controller, onChanged: (v) => setState(() => _query = v)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _Chip(label: context.strings.allCategories, selected: _category == null, onTap: () => setState(() => _category = null)),
              ...categories.map((c) => _Chip(
                    label: c,
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  )),
            ],
          ),
          const SizedBox(height: 28),
          Text(context.strings.resultsCount(results.length),
              style: AppFonts.body(color: context.colors.creamDim, size: 13.5)),
          const SizedBox(height: 16),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(context.strings.noResults,
                    style: AppFonts.body(color: context.colors.creamDim, size: 14)),
              ),
            )
          else
            ProductGrid(
              products: results,
              onProductTap: (p) => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: context.colors.cream.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppFonts.body(size: 14.5, color: context.colors.cream),
        cursorColor: context.colors.orchid,
        decoration: InputDecoration(
          hintText: context.strings.searchHint,
          hintStyle: AppFonts.body(size: 14, color: context.colors.creamDim),
          prefixIcon: Icon(Icons.search_rounded, color: context.colors.creamDim),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          gradient: selected ? context.colors.violetGradient : null,
          color: selected ? null : context.colors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? Colors.transparent : context.colors.cream.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.label(
            size: 14.5,
            color: selected ? Colors.white : context.colors.creamDim,
            letterSpacing: 0.8,
            text: label,
          ),
        ),
      ),
    );
  }
}
