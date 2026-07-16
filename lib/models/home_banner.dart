/// Which banner strip on the Home page a slide belongs to — the same
/// `home_banners` table backs both strips, just filtered by this column.
class HomeBannerPlacement {
  /// The strip near the very top of Home.
  static const hero = 'hero';
  /// The strip right above the "MOST ORDERED" section, further down.
  static const mostOrdered = 'most_ordered';
}

/// A single slide in one of the promotional banner strips on the Home
/// page (e.g. "free shipping over 299", seasonal offers, new drops).
/// Owner-managed from the admin dashboard — same shape and same
/// singleton-table pattern as [AboutSlide]. [placement] says which of the
/// two strips (see [HomeBannerPlacement]) this slide shows up in.
class HomeBanner {
  final String id;
  final String imageUrl;
  final int sortOrder;
  final String placement;

  const HomeBanner({
    required this.id,
    required this.imageUrl,
    this.sortOrder = 0,
    this.placement = HomeBannerPlacement.hero,
  });

  factory HomeBanner.fromRow(Map<String, dynamic> row) => HomeBanner(
        id: row['id'] as String,
        imageUrl: (row['image_url'] as String?) ?? '',
        sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
        placement: (row['placement'] as String?) ?? HomeBannerPlacement.hero,
      );
}
