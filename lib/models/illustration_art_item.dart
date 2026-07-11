/// One tappable circle in the "Illustration & Art" row on the storefront's
/// Home page — a photo plus a bilingual title. Fully owner-managed from
/// the admin dashboard (add/edit/delete/reorder), unlike the fixed
/// three-item Services row above it.
class IllustrationArtItem {
  final String id;
  final String titleEn;
  final String titleAr;
  final String imageUrl;
  final int sortOrder;

  const IllustrationArtItem({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  /// Picks the right title for the current language, falling back to
  /// whichever one was actually filled in if the other was left blank.
  String title(bool isArabic) {
    if (isArabic) return titleAr.isNotEmpty ? titleAr : titleEn;
    return titleEn.isNotEmpty ? titleEn : titleAr;
  }

  factory IllustrationArtItem.fromRow(Map<String, dynamic> row) => IllustrationArtItem(
        id: row['id'] as String,
        titleEn: (row['title'] as String?) ?? '',
        titleAr: (row['title_ar'] as String?) ?? '',
        imageUrl: (row['image_url'] as String?) ?? '',
        sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      );
}
