/// A single customer quote — plain static data, no backend involved.
/// See lib/data/testimonials.dart for the actual list to edit.
class Testimonial {
  final String nameEn;
  final String nameAr;
  final String quoteEn;
  final String quoteAr;
  final int rating; // 1-5

  const Testimonial({
    required this.nameEn,
    required this.nameAr,
    required this.quoteEn,
    required this.quoteAr,
    this.rating = 5,
  });

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
  String quote(bool isArabic) => isArabic ? quoteAr : quoteEn;
}
