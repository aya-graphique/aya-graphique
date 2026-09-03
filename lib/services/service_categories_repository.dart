/// Thumbnail images for the three fixed service categories (Mentoring /
/// Designing / Private Workshop) shown on the storefront's Home page
/// category-circles row, keyed by each category's fixed index in
/// `kServiceCategories` (see graphical_services_screen.dart).
///
/// This used to be owner-managed from the admin dashboard (upload/replace/
/// remove per category, stored in Supabase). It's now hardcoded instead
/// (bundled into the app itself) to save bandwidth, since these three
/// photos rarely change. The admin dashboard no longer has a screen for
/// this — to change a photo, replace its file under assets/images/ (or
/// point [_hardcodedImages] at a new one below), then run
/// `flutter build web --release` and redeploy.
class ServiceCategoriesRepository {
  static const Map<int, String> _hardcodedImages = {
    0: 'assets/images/service_mentoring.jpg', // Mentoring
    1: 'assets/images/service_designing.jpg', // Designing
    2: 'assets/images/service_workshop.jpg', // Private Workshop
  };

  /// All thumbnails, keyed by category index. A category with no entry
  /// here just falls back to its icon — see HomeScreen's `_CategoryCircle`.
  static Future<Map<int, String>> fetchImages() async => _hardcodedImages;
}
