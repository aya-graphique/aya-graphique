import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';
import '../../models/illustration_art_item.dart';
import '../../services/illustration_art_repository.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

/// Lets the owner manage the "Illustration & Art" circles row on the
/// public Home page — add a new circle (photo + English/Arabic title),
/// edit a title, delete one, or drag to reorder. Maps straight onto the
/// `_IllustrationArtSection` widget in `HomeScreen`.
class AdminIllustrationArtScreen extends StatefulWidget {
  const AdminIllustrationArtScreen({super.key});

  @override
  State<AdminIllustrationArtScreen> createState() => _AdminIllustrationArtScreenState();
}

class _AdminIllustrationArtScreenState extends State<AdminIllustrationArtScreen> {
  List<IllustrationArtItem> _items = [];
  bool _loading = true;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await IllustrationArtRepository.fetchAll();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _addItem() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() => _error = 'Connect Supabase first (see lib/config/supabase_config.dart).');
      return;
    }
    final titles = await _promptTitles(context);
    if (titles == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _error = 'Couldn\'t read that file. Try a different photo.');
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      final url = await StorageService.uploadIllustrationArtImage(bytes, file.name);
      await IllustrationArtRepository.addItem(
        titleEn: titles.$1,
        titleAr: titles.$2,
        imageUrl: url,
        sortOrder: _items.length,
      );
      await _load();
    } catch (e) {
      setState(() => _error = 'Couldn\'t upload photo: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _editItem(IllustrationArtItem item) async {
    final titles = await _promptTitles(context, initialEn: item.titleEn, initialAr: item.titleAr);
    if (titles == null) return;
    try {
      await IllustrationArtRepository.updateItem(item.id, titleEn: titles.$1, titleAr: titles.$2);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t save: $e')),
      );
    }
  }

  /// Simple two-field dialog for the English/Arabic title. Returns null if
  /// cancelled.
  Future<(String, String)?> _promptTitles(
    BuildContext context, {
    String initialEn = '',
    String initialAr = '',
  }) {
    final enController = TextEditingController(text: initialEn);
    final arController = TextEditingController(text: initialAr);
    return showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        title: Text('Circle title', style: AppFonts.body(size: 16, color: context.colors.cream)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: enController,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: AppFonts.body(size: 14, color: context.colors.cream),
              decoration: InputDecoration(
                labelText: 'Title (English)',
                labelStyle: AppFonts.body(size: 13, color: context.colors.creamDim),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: arController,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: AppFonts.body(size: 14, color: context.colors.cream),
              decoration: InputDecoration(
                labelText: 'Title (Arabic)',
                labelStyle: AppFonts.body(size: 13, color: context.colors.creamDim),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: AppFonts.body(size: 14, color: context.colors.creamDim)),
          ),
          TextButton(
            onPressed: () {
              final en = enController.text.trim();
              final ar = arController.text.trim();
              if (en.isEmpty && ar.isEmpty) return;
              Navigator.of(context).pop((en, ar));
            },
            child: Text('Save', style: AppFonts.body(size: 14, color: context.colors.orchid)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(IllustrationArtItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        title: Text('Remove this circle?', style: AppFonts.body(size: 16, color: context.colors.cream)),
        content: Text(
          'It will disappear from the "Illustration & Art" row on the Home page.',
          style: AppFonts.body(size: 13, color: context.colors.creamDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppFonts.body(size: 14, color: context.colors.creamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Remove', style: AppFonts.body(size: 14, color: context.colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await IllustrationArtRepository.deleteItem(item.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t remove circle: $e')),
      );
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    try {
      await IllustrationArtRepository.reorderItems(_items);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t save the new order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.forceArabic = false;
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Illustration & Art',
            style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
          children: [
            Text(
              'The circles shown in the "Illustration & Art" row on the '
              'Home page, right under Services. Each circle is a photo '
              'plus a title (English & Arabic). Drag to reorder.',
              style: AppFonts.body(size: 13, color: context.colors.creamDim),
            ),
            const SizedBox(height: 20),
            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                  ),
                ),
              )
            else if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border(0.08)),
                ),
                child: Text('No circles yet — add the first one below.',
                    style: AppFonts.body(size: 13, color: context.colors.creamDim)),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _items.length,
                onReorder: _reorder,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return _ItemRow(
                    key: ValueKey(item.id),
                    index: i,
                    item: item,
                    onEdit: () => _editItem(item),
                    onDelete: () => _deleteItem(item),
                  );
                },
              ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _uploading ? null : _addItem,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border(0.1)),
                ),
                child: _uploading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 18, color: context.colors.orchid),
                          const SizedBox(width: 8),
                          Text('Add circle',
                              style: AppFonts.body(size: 13.5, weight: FontWeight.w600, color: context.colors.cream)),
                        ],
                      ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: AppFonts.body(size: 12.5, color: context.colors.danger)),
            ],
          ],
        ),
      ),
    );
  }
}

/// One row in the circle list. Thumbnail, title, a drag handle to
/// reorder, an edit button, and a delete button.
class _ItemRow extends StatelessWidget {
  final IllustrationArtItem item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.titleEn.isNotEmpty ? item.titleEn : item.titleAr;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Icon(Icons.drag_handle_rounded, color: context.colors.creamDim),
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: context.colors.surfaceRaised,
                  child: Icon(Icons.image_outlined, color: context.colors.creamDim, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.isEmpty ? '(no title)' : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.body(size: 13.5, weight: FontWeight.w600, color: context.colors.cream),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, color: context.colors.creamDim, size: 20),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: context.colors.danger, size: 20),
          ),
        ],
      ),
    );
  }
}
