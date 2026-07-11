import 'package:flutter/material.dart';
import '../../models/service_override.dart';
import '../../services/services_repository.dart';
import '../../theme/app_theme.dart';
import '../graphical_services_screen.dart';

/// Edit form for one existing "Services" item. Only text and pricing can
/// change here — every field is optional, and leaving one blank means
/// "keep the original copy" rather than "show nothing".
class AdminServiceItemEditScreen extends StatefulWidget {
  final String itemKey;
  final ServiceItem baseItem;
  final ServiceOverride? existingOverride;

  const AdminServiceItemEditScreen({
    super.key,
    required this.itemKey,
    required this.baseItem,
    required this.existingOverride,
  });

  @override
  State<AdminServiceItemEditScreen> createState() => _AdminServiceItemEditScreenState();
}

class _AdminServiceItemEditScreenState extends State<AdminServiceItemEditScreen> {
  late final _title = TextEditingController(text: widget.existingOverride?.title ?? '');
  late final _titleAr = TextEditingController(text: widget.existingOverride?.titleAr ?? '');
  late final _subtitle = TextEditingController(text: widget.existingOverride?.subtitle ?? '');
  late final _subtitleAr = TextEditingController(text: widget.existingOverride?.subtitleAr ?? '');
  late final _description = TextEditingController(text: widget.existingOverride?.description ?? '');
  late final _descriptionAr = TextEditingController(text: widget.existingOverride?.descriptionAr ?? '');
  late final _highlights =
      TextEditingController(text: (widget.existingOverride?.highlights ?? const []).join('\n'));
  late final _highlightsAr =
      TextEditingController(text: (widget.existingOverride?.highlightsAr ?? const []).join('\n'));
  late final _priceLines =
      TextEditingController(text: (widget.existingOverride?.priceLines ?? const []).join('\n'));
  late final _priceLinesAr =
      TextEditingController(text: (widget.existingOverride?.priceLinesAr ?? const []).join('\n'));
  late final _note = TextEditingController(text: widget.existingOverride?.note ?? '');
  late final _noteAr = TextEditingController(text: widget.existingOverride?.noteAr ?? '');

  bool _saving = false;
  bool _resetting = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [
      _title,
      _titleAr,
      _subtitle,
      _subtitleAr,
      _description,
      _descriptionAr,
      _highlights,
      _highlightsAr,
      _priceLines,
      _priceLinesAr,
      _note,
      _noteAr,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _lines(TextEditingController c) =>
      c.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final override = ServiceOverride(
      key: widget.itemKey,
      title: _title.text.trim(),
      titleAr: _titleAr.text.trim(),
      subtitle: _subtitle.text.trim(),
      subtitleAr: _subtitleAr.text.trim(),
      description: _description.text.trim(),
      descriptionAr: _descriptionAr.text.trim(),
      highlights: _lines(_highlights),
      highlightsAr: _lines(_highlightsAr),
      priceLines: _lines(_priceLines),
      priceLinesAr: _lines(_priceLinesAr),
      note: _note.text.trim(),
      noteAr: _noteAr.text.trim(),
    );
    try {
      await ServicesRepository.saveOverride(override);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Couldn\'t save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surfaceRaised,
        title: Text('Reset to default?', style: AppFonts.body(size: 16, color: context.colors.cream)),
        content: Text(
          'This clears everything you\'ve typed here and goes back to the '
          'original text and price for this item.',
          style: AppFonts.body(size: 13, color: context.colors.creamDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppFonts.body(size: 14, color: context.colors.creamDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Reset', style: AppFonts.body(size: 14, color: context.colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _resetting = true);
    try {
      await ServicesRepository.resetOverride(widget.itemKey);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _resetting = false;
        _error = 'Couldn\'t reset: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppFonts.forceArabic = false;
    final base = widget.baseItem;
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        backgroundColor: context.colors.bgDeep,
        elevation: 0,
        title: Text('Edit item',
            style: AppFonts.display(color: context.colors.cream, size: 20, weight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
          children: [
            Text(
              'Leave any field blank to keep the original text shown below '
              'as a placeholder.',
              style: AppFonts.body(size: 12.5, color: context.colors.creamDim),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _Field(label: 'Title', controller: _title, hint: base.title.en)),
                const SizedBox(width: 14),
                Expanded(child: _Field(label: 'Title — Arabic', controller: _titleAr, hint: base.title.ar)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _Field(label: 'Subtitle', controller: _subtitle, hint: base.subtitle?.en ?? '')),
                const SizedBox(width: 14),
                Expanded(
                    child:
                        _Field(label: 'Subtitle — Arabic', controller: _subtitleAr, hint: base.subtitle?.ar ?? '')),
              ],
            ),
            const SizedBox(height: 16),
            _Field(label: 'Description', controller: _description, hint: base.description?.en ?? '', maxLines: 4),
            const SizedBox(height: 16),
            _Field(
              label: 'Description — Arabic',
              controller: _descriptionAr,
              hint: base.description?.ar ?? '',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Highlights (one per line)',
              controller: _highlights,
              hint: base.highlights.map((h) => h.en).join('\n'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Highlights — Arabic (one per line)',
              controller: _highlightsAr,
              hint: base.highlights.map((h) => h.ar).join('\n'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Price lines (one per line)',
              controller: _priceLines,
              hint: base.priceLines.map((p) => p.en).join('\n'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Price lines — Arabic (one per line)',
              controller: _priceLinesAr,
              hint: base.priceLines.map((p) => p.ar).join('\n'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _Field(label: 'Note', controller: _note, hint: base.note?.en ?? ''),
            const SizedBox(height: 16),
            _Field(label: 'Note — Arabic', controller: _noteAr, hint: base.note?.ar ?? ''),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: AppFonts.body(size: 13, color: context.colors.danger)),
            ],
            const SizedBox(height: 26),
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
                    : Text('Save changes',
                        style: AppFonts.label(size: 14, color: Colors.white, letterSpacing: 1.4)
                            .copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            if (widget.existingOverride != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _resetting ? null : _resetToDefault,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: context.colors.danger.withOpacity(0.4)),
                  ),
                  child: _resetting
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.danger),
                        )
                      : Text('Reset to default',
                          style: AppFonts.label(size: 13, color: context.colors.danger, letterSpacing: 1.0)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  // null = auto-grow: wraps onto new lines as the text gets long instead
  // of scrolling sideways in a fixed single line (which used to hide half
  // of what you'd typed). Fields that truly want a hard cap (e.g. exactly
  // N lines for "one per line" inputs) still pass an explicit number.
  final int? maxLines;
  final String? hint;

  const _Field({required this.label, required this.controller, this.maxLines, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.label(color: context.colors.orchid, size: 11, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border(0.08)),
          ),
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: maxLines,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: AppFonts.body(size: 14, color: context.colors.cream),
            cursorColor: context.colors.orchid,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: (hint == null || hint!.isEmpty) ? null : hint,
              hintStyle: AppFonts.body(size: 13, color: context.colors.creamDim.withOpacity(0.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
