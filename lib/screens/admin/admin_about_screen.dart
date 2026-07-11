import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';
import '../../models/about_me.dart';
import '../../services/about_repository.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

/// Lets the owner manage the photos in the slideshow at the top of the
/// public "Who am I" page — nothing else on that page is editable from
/// here. Maps straight onto the slideshow in `WhoAmIScreen`.
class AdminAboutScreen extends StatefulWidget {
  const AdminAboutScreen({super.key});

  @override
  State<AdminAboutScreen> createState() => _AdminAboutScreenState();
}

class _AdminAboutScreenState extends State<AdminAboutScreen> {
  List<AboutSlide> _slides = [];
  bool _loadingSlides = true;
  bool _uploadingSlide = false;
  String? _slidesError;

  @override
  void initState() {
    super.initState();
    _loadSlides();
  }

  Future<void> _loadSlides() async {
    setState(() => _loadingSlides = true);
    final slides = await AboutRepository.fetchSlides();
    if (!mounted) return;
    setState(() {
      _slides = slides;
      _loadingSlides = false;
    });
  }

  Future<void> _addSlide() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() => _slidesError = 'Connect Supabase first (see lib/config/supabase_config.dart).');
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
      setState(() => _slidesError = 'Couldn\'t read that file. Try a different photo.');
      return;
    }

    setState(() {
      _uploadingSlide = true;
      _slidesError = null;
    });
    try {
      final url = await StorageService.uploadAboutImage(bytes, file.name);
      await AboutRepository.addSlide(url, sortOrder: _slides.length);
      await _loadSlides();
    } catch (e) {
      setState(() => _slidesError = 'Couldn\'t upload photo: $e');
    } finally {
      if (mounted) setState(() => _uploadingSlide = false);
    }
  }

  Future<void> _deleteSlide(AboutSlide slide) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        title: Text('Remove this photo?', style: AppFonts.body(size: 16, color: context.colors.cream)),
        content: Text(
          'It will disappear from the slideshow on the "Who am I" page.',
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
      await AboutRepository.deleteSlide(slide.id);
      _loadSlides();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t remove photo: $e')),
      );
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _slides.removeAt(oldIndex);
      _slides.insert(newIndex, item);
    });
    try {
      await AboutRepository.reorderSlides(_slides);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn\'t save the new order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The storefront's Arabic-font toggle sets a global static flag
    // (AppFonts.forceArabic). The admin dashboard never offers that
    // toggle and always stays in English, so force it off here on every
    // build regardless of what a shopper picked on the storefront.
    AppFonts.forceArabic = false;
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Slideshow photos',
            style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
          children: [
            Text(
              'The images that scroll at the top of the "Who am I" page. '
              'Drag to reorder. Each photo automatically displays at its '
              'real proportions — no cropping, nothing to set up.',
              style: AppFonts.body(size: 13, color: context.colors.creamDim),
            ),
            const SizedBox(height: 20),
            if (_loadingSlides)
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
            else if (_slides.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border(0.08)),
                ),
                child: Text('No photos yet — add the first one below.',
                    style: AppFonts.body(size: 13, color: context.colors.creamDim)),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Flutter's ReorderableListView auto-adds its own drag
                // handle on the trailing edge on desktop/web platforms —
                // that's what was overlapping our delete button on the
                // right. Turning it off and wiring our own left-side
                // handle icon (via ReorderableDragStartListener, in
                // _SlideRow) as the sole drag trigger removes the clash.
                buildDefaultDragHandles: false,
                itemCount: _slides.length,
                onReorder: _reorder,
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return _SlideRow(
                    key: ValueKey(slide.id),
                    index: i,
                    slide: slide,
                    onDelete: () => _deleteSlide(slide),
                  );
                },
              ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _uploadingSlide ? null : _addSlide,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.colors.border(0.1)),
                ),
                child: _uploadingSlide
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
                          Text('Add photo',
                              style: AppFonts.body(size: 13.5, weight: FontWeight.w600, color: context.colors.cream)),
                        ],
                      ),
              ),
            ),
            if (_slidesError != null) ...[
              const SizedBox(height: 8),
              Text(_slidesError!, style: AppFonts.body(size: 12.5, color: context.colors.danger)),
            ],
          ],
        ),
      ),
    );
  }
}

/// One row in the photo list. Just a thumbnail, a drag handle to reorder,
/// and a delete button — the app detects each photo's real proportions on
/// its own, so there's nothing to type in here.
class _SlideRow extends StatelessWidget {
  final AboutSlide slide;
  final int index;
  final VoidCallback onDelete;
  const _SlideRow({super.key, required this.slide, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
              width: 56,
              height: 44,
              child: Image.network(
                slide.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: context.colors.surfaceRaised,
                  child: Icon(Icons.image_outlined, color: context.colors.creamDim, size: 18),
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: context.colors.danger, size: 20),
          ),
        ],
      ),
    );
  }
}
