/// A single slide in the promotional banner strip shown near the top of
/// the Home page (e.g. "free shipping over 299", seasonal offers, new
/// drops). Owner-managed from the admin dashboard — same shape and same
/// singleton-table pattern as [AboutSlide].
class HomeBanner {
  final String id;
  final String imageUrl;
  final int sortOrder;

  const HomeBanner({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  factory HomeBanner.fromRow(Map<String, dynamic> row) => HomeBanner(
        id: row['id'] as String,
        imageUrl: (row['image_url'] as String?) ?? '',
        sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      );
}
