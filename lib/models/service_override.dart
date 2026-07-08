/// An owner-editable override for one item on the "Services" page.
///
/// The page's structure (which categories exist, which items are inside
/// each one) stays fixed in code — the owner can only change the *text and
/// prices* of an item that already exists, not add or remove items. Each
/// override is keyed by `"<categoryIndex>-<itemIndex>"`, which is stable
/// because the list of categories/items never changes from the dashboard.
///
/// Every field is optional. An empty field means "keep showing the
/// original copy from the code" — the storefront only swaps in a field
/// once the owner has actually typed something into it, so a half-filled
/// edit never blanks out the rest of the card.
class ServiceOverride {
  final String key;
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final String description;
  final String descriptionAr;
  final List<String> highlights;
  final List<String> highlightsAr;
  final List<String> priceLines;
  final List<String> priceLinesAr;
  final String note;
  final String noteAr;

  const ServiceOverride({
    required this.key,
    this.title = '',
    this.titleAr = '',
    this.subtitle = '',
    this.subtitleAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.highlights = const [],
    this.highlightsAr = const [],
    this.priceLines = const [],
    this.priceLinesAr = const [],
    this.note = '',
    this.noteAr = '',
  });

  factory ServiceOverride.fromRow(Map<String, dynamic> row) => ServiceOverride(
        key: row['item_key'] as String,
        title: (row['title'] as String?) ?? '',
        titleAr: (row['title_ar'] as String?) ?? '',
        subtitle: (row['subtitle'] as String?) ?? '',
        subtitleAr: (row['subtitle_ar'] as String?) ?? '',
        description: (row['description'] as String?) ?? '',
        descriptionAr: (row['description_ar'] as String?) ?? '',
        highlights: ((row['highlights'] as List?) ?? const []).map((e) => e.toString()).toList(),
        highlightsAr: ((row['highlights_ar'] as List?) ?? const []).map((e) => e.toString()).toList(),
        priceLines: ((row['price_lines'] as List?) ?? const []).map((e) => e.toString()).toList(),
        priceLinesAr: ((row['price_lines_ar'] as List?) ?? const []).map((e) => e.toString()).toList(),
        note: (row['note'] as String?) ?? '',
        noteAr: (row['note_ar'] as String?) ?? '',
      );

  Map<String, dynamic> toRow() => {
        'item_key': key,
        'title': title,
        'title_ar': titleAr,
        'subtitle': subtitle,
        'subtitle_ar': subtitleAr,
        'description': description,
        'description_ar': descriptionAr,
        'highlights': highlights,
        'highlights_ar': highlightsAr,
        'price_lines': priceLines,
        'price_lines_ar': priceLinesAr,
        'note': note,
        'note_ar': noteAr,
      };
}
