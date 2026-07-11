import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';
import '../../models/service_override.dart';
import '../../services/service_categories_repository.dart';
import '../../services/services_repository.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../graphical_services_screen.dart';
import 'admin_service_item_edit_screen.dart';

/// Lets the owner tweak the text and prices already on the public
/// "Services" page. The categories and items themselves are fixed in
/// code — nothing here can add or remove one, only change what an
/// existing item says and costs (plus each category's thumbnail image,
/// shown on the Home page's category-circles row).
class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  Map<String, ServiceOverride> _overrides = {};
  Map<int, String> _categoryImages = {};
  // Which category index is currently mid-upload, so only that one row
  // shows a spinner instead of the whole page.
  final Set<int> _uploadingCategoryImage = {};
  String? _categoryImageError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final overrides = await ServicesRepository.fetchOverrides();
    final categoryImages = await ServiceCategoriesRepository.fetchImages();
    if (!mounted) return;
    setState(() {
      _overrides = overrides;
      _categoryImages = categoryImages;
      _loading = false;
    });
  }

  Future<void> _pickCategoryImage(int categoryIndex) async {
    if (!SupabaseConfig.isConfigured) {
      setState(() => _categoryImageError = 'Connect Supabase first (see lib/config/supabase_config.dart).');
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // loads bytes directly, works on web + mobile + desktop
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _categoryImageError = 'Couldn\'t read that file. Try a different photo.');
      return;
    }

    setState(() {
      _uploadingCategoryImage.add(categoryIndex);
      _categoryImageError = null;
    });
    try {
      final url = await StorageService.uploadServiceCategoryImage(bytes, file.name);
      await ServiceCategoriesRepository.setImage(categoryIndex, url);
      if (!mounted) return;
      setState(() => _categoryImages = {..._categoryImages, categoryIndex: url});
    } catch (e) {
      setState(() => _categoryImageError = 'Couldn\'t upload photo: $e');
    } finally {
      if (mounted) setState(() => _uploadingCategoryImage.remove(categoryIndex));
    }
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
                        'keeps showing its original text. Tap a category\'s circle '
                        'to give it a thumbnail photo, shown on the Home page.',
                        style: AppFonts.body(size: 13, color: context.colors.creamDim),
                      ),
                      if (_categoryImageError != null) ...[
                        const SizedBox(height: 10),
                        Text(_categoryImageError!,
                            style: AppFonts.body(size: 12.5, color: Colors.redAccent)),
                      ],
                      const SizedBox(height: 20),
                      for (var i = 0; i < kServiceCategories.length; i++) ...[
                        _CategorySection(
                          category: kServiceCategories[i],
                          categoryIndex: i,
                          overrides: _overrides,
                          imageUrl: _categoryImages[i],
                          uploading: _uploadingCategoryImage.contains(i),
                          onEditItem: (j) => _editItem(i, j),
                          onPickImage: () => _pickCategoryImage(i),
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
  final String? imageUrl;
  final bool uploading;
  final ValueChanged<int> onEditItem;
  final VoidCallback onPickImage;

  const _CategorySection({
    required this.category,
    required this.categoryIndex,
    required this.overrides,
    required this.imageUrl,
    required this.uploading,
    required this.onEditItem,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: uploading ? null : onPickImage,
              child: Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.surfaceRaised,
                  border: Border.all(color: context.colors.cream.withOpacity(0.12)),
                ),
                child: uploading
                    ? Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageUrl != null && imageUrl!.isNotEmpty)
                            Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(category.icon, size: 18, color: context.colors.orchid),
                            )
                          else
                            Center(child: Icon(category.icon, size: 18, color: context.colors.orchid)),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.colors.bgDeep,
                              ),
                              child: Icon(Icons.edit_rounded, size: 9, color: context.colors.creamDim),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(width: 10),
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
