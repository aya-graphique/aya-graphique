import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../config/supabase_config.dart';
import '../../models/product.dart';
import '../../services/categories_repository.dart';
import '../../services/products_repository.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';

/// Add or edit a single product. Every field the storefront cares about is
/// editable here — name, description, price, category, image, tags,
/// rating, and stock. Category is a free-text field backed by a dropdown of
/// previously used names, with a one-tap way to create a brand new one.
class AdminProductFormScreen extends StatefulWidget {
  final Product? existing;
  const AdminProductFormScreen({super.key, this.existing});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _description = TextEditingController(text: widget.existing?.description ?? '');
  late final _price = TextEditingController(text: widget.existing?.price.toString() ?? '');
  late final _imageUrl = TextEditingController(text: widget.existing?.imageUrl ?? '');
  late final _tags = TextEditingController(text: widget.existing?.tags.join(', ') ?? '');
  late final _rating = TextEditingController(text: widget.existing?.rating.toString() ?? '4.8');
  late final _stock = TextEditingController(text: widget.existing?.stock.toString() ?? '0');
  late final _sortOrder = TextEditingController(text: widget.existing?.sortOrder.toString() ?? '0');
  final _newCategory = TextEditingController();

  List<String> _knownCategories = [];
  String? _selectedCategory;
  bool _addingNewCategory = false;
  bool _loadingCategories = true;
  bool _saving = false;
  bool _uploadingImage = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.existing?.category;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await CategoriesRepository.fetchAll();
    if (!mounted) return;
    setState(() {
      _knownCategories = categories;
      // If editing a product whose category isn't in the known list yet,
      // still show it as selected.
      if (_selectedCategory != null && !_knownCategories.contains(_selectedCategory)) {
        _knownCategories = [..._knownCategories, _selectedCategory!]..sort();
      }
      _loadingCategories = false;
      if (_selectedCategory == null && _knownCategories.isEmpty) {
        _addingNewCategory = true;
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _imageUrl.dispose();
    _tags.dispose();
    _rating.dispose();
    _stock.dispose();
    _sortOrder.dispose();
    _newCategory.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    if (!SupabaseConfig.isConfigured) {
      setState(() => _error = 'Connect Supabase first (see lib/config/supabase_config.dart).');
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
      setState(() => _error = 'Couldn\'t read that file. Try a different photo.');
      return;
    }

    setState(() {
      _uploadingImage = true;
      _error = null;
    });
    try {
      final url = await StorageService.uploadProductImage(bytes, file.name);
      setState(() => _imageUrl.text = url);
    } catch (e) {
      setState(() => _error = 'Couldn\'t upload photo: $e');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _save() async {
    final categoryName = _addingNewCategory ? _newCategory.text.trim() : (_selectedCategory ?? '');
    if (!_formKey.currentState!.validate() || categoryName.isEmpty) {
      setState(() => _error = categoryName.isEmpty ? 'Pick or create a category.' : null);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final product = Product(
      id: widget.existing?.id ?? '',
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? 0,
      category: categoryName,
      imageUrl: _imageUrl.text.trim(),
      tags: _tags.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      rating: double.tryParse(_rating.text.trim()) ?? 4.8,
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
    );

    try {
      await CategoriesRepository.ensureExists(categoryName);
      if (_isEditing) {
        await ProductsRepository.update(widget.existing!.id, product);
      } else {
        await ProductsRepository.create(product);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Couldn\'t save: $e';
      });
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
        title: Text(_isEditing ? 'Edit product' : 'Add product',
            style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _TextField(label: 'Name', controller: _name, required: true),
              const SizedBox(height: 16),
              _TextField(label: 'Description', controller: _description, maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TextField(
                      label: 'Price (EGP)',
                      controller: _price,
                      required: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _TextField(
                      label: 'Stock',
                      controller: _stock,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CategoryPicker(
                loading: _loadingCategories,
                categories: _knownCategories,
                selected: _selectedCategory,
                addingNew: _addingNewCategory,
                newCategoryController: _newCategory,
                onSelect: (c) => setState(() {
                  _selectedCategory = c;
                  _addingNewCategory = false;
                }),
                onAddNew: () => setState(() {
                  _addingNewCategory = true;
                  _selectedCategory = null;
                }),
              ),
              const SizedBox(height: 16),
              Text('Photo', style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.4)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _uploadingImage ? null : _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: context.colors.border(0.1)),
                        ),
                        child: _uploadingImage
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.upload_rounded, size: 18, color: context.colors.orchid),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Upload a photo from your device',
                                    style: AppFonts.body(size: 13.5, weight: FontWeight.w600, color: context.colors.cream),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _TextField(label: 'Or paste an image URL', controller: _imageUrl, onChanged: () => setState(() {})),
              if (_imageUrl.text.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imageUrl.text.trim(),
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      alignment: Alignment.center,
                      color: context.colors.surface,
                      child: Text('Image preview unavailable',
                          style: AppFonts.body(size: 12, color: context.colors.creamDim)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _TextField(label: 'Tags (comma separated)', controller: _tags),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TextField(
                      label: 'Rating (0–5)',
                      controller: _rating,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _TextField(
                      label: 'Sort order',
                      controller: _sortOrder,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 18),
                Text(_error!, style: AppFonts.body(size: 13, color: context.colors.danger)),
              ],
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: context.colors.violetGradient,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isEditing ? 'Save changes' : 'Add product',
                          style: AppFonts.label(size: 14, color: Colors.white, letterSpacing: 1.4)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final bool loading;
  final List<String> categories;
  final String? selected;
  final bool addingNew;
  final TextEditingController newCategoryController;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddNew;

  const _CategoryPicker({
    required this.loading,
    required this.categories,
    required this.selected,
    required this.addingNew,
    required this.newCategoryController,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        if (loading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.orchid),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...categories.map(
                (c) => _CategoryChip(
                  label: c,
                  selected: !addingNew && selected == c,
                  onTap: () => onSelect(c),
                ),
              ),
              _CategoryChip(
                label: '+ New category',
                selected: addingNew,
                onTap: onAddNew,
              ),
            ],
          ),
        if (addingNew) ...[
          const SizedBox(height: 12),
          _TextField(
            label: 'New category name',
            controller: newCategoryController,
            autofocus: true,
          ),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? context.colors.violetGradient : null,
          color: selected ? null : context.colors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? Colors.transparent : context.colors.border(0.1),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.body(
            size: 13,
            weight: FontWeight.w600,
            color: selected ? Colors.white : context.colors.creamDim,
            text: label,
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool autofocus;
  final VoidCallback? onChanged;

  const _TextField({
    required this.label,
    required this.controller,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.4)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border(0.08)),
          ),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              return TextFormField(
                controller: controller,
                maxLines: maxLines,
                keyboardType: keyboardType,
                autofocus: autofocus,
                onChanged: onChanged == null ? null : (_) => onChanged!(),
                textDirection: AppFonts.isArabic(value.text) ? TextDirection.rtl : TextDirection.ltr,
                style: AppFonts.body(size: 14.5, color: context.colors.cream, text: value.text),
                cursorColor: context.colors.orchid,
                validator: required
                    ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
                    : null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
