import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';
import '../../models/service_override.dart';
import '../../services/services_repository.dart';
import '../../theme/app_theme.dart';
import '../graphical_services_screen.dart';
import 'admin_service_item_edit_screen.dart';

/// Lets the owner tweak the text and prices already on the public
/// "Services" page. The categories and items themselves are fixed in
/// code — nothing here can add or remove one, only change what an
/// existing item says and costs.
class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  Map<String, ServiceOverride> _overrides = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final overrides = await ServicesRepository.fetchOverrides();
    if (!mounted) return;
    setState(() {
      _overrides = overrides;
      _loading = false;
    });
  }

  Future<void> _editItem(int categoryIndex, int itemIndex) async {
    final key = serviceItemKey(categoryIndex, itemIndex);
    final baseItem = kServiceCategories[categoryIndex].items[itemIndex];
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminServiceItemEditScreen(
          itemKey: key,
          baseItem: baseItem,
          existingOverride: _overrides[key],
        ),
      ),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.forceArabic = false;
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Services',
            style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: !SupabaseConfig.isConfigured
            ? Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Connect Supabase first (see lib/config/supabase_config.dart) '
                  'to save edits here.',
                  style: AppFonts.body(size: 13.5, color: context.colors.creamDim),
                ),
              )
            : _loading
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
                    children: [
                      Text(
                        'Tap an item to edit its title, description, highlights, '
                        'price, or note. Leaving a field blank on the edit screen '
                        'keeps showing its original text.',
                        style: AppFonts.body(size: 13, color: context.colors.creamDim),
                      ),
                      const SizedBox(height: 20),
                      for (var i = 0; i < kServiceCategories.length; i++) ...[
                        _CategorySection(
                          category: kServiceCategories[i],
                          categoryIndex: i,
                          overrides: _overrides,
                          onEditItem: (j) => _editItem(i, j),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final ServiceCategory category;
  final int categoryIndex;
  final Map<String, ServiceOverride> overrides;
  final ValueChanged<int> onEditItem;

  const _CategorySection({
    required this.category,
    required this.categoryIndex,
    required this.overrides,
    required this.onEditItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, size: 18, color: context.colors.orchid),
            const SizedBox(width: 8),
            Text(category.title.en,
                style: AppFonts.display(color: context.colors.cream, size: 16, weight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 10),
        for (var j = 0; j < category.items.length; j++)
          _ItemTile(
            item: applyServiceOverride(category.items[j], overrides[serviceItemKey(categoryIndex, j)]),
            hasOverride: overrides.containsKey(serviceItemKey(categoryIndex, j)),
            onTap: () => onEditItem(j),
          ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final ServiceItem item;
  final bool hasOverride;
  final VoidCallback onTap;

  const _ItemTile({required this.item, required this.hasOverride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colors.cream.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title.en,
                      style: AppFonts.body(size: 14, weight: FontWeight.w600, color: context.colors.cream)),
                  if (item.priceLines.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(item.priceLines.map((p) => p.en).join(' · '),
                        style: AppFonts.body(size: 12, color: context.colors.creamDim)),
                  ],
                ],
              ),
            ),
            if (hasOverride)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text('edited',
                    style: AppFonts.label(size: 9.5, color: context.colors.orchid, letterSpacing: 0.6)),
              ),
            Icon(Icons.edit_outlined, size: 17, color: context.colors.creamDim),
          ],
        ),
      ),
    );
  }
}
