/// A customer-submitted testimonial, stored in Supabase's `testimonials`
/// table. Submitted from the storefront (see [TestimonialsRepository.submit])
/// and hidden from the public "What people say" section until the owner
/// approves it from the admin dashboard.
///
/// Unlike most other bilingual content in this app, a testimonial is shown
/// exactly as the customer typed it — there's no separate English/Arabic
/// version, since it's their own words, not owner-authored copy.
class Testimonial {
  final String id;
  final String name;
  final String quote;
  final int rating; // 1-5
  final bool isApproved;
  final DateTime createdAt;

  const Testimonial({
    required this.id,
    required this.name,
    required this.quote,
    this.rating = 5,
    this.isApproved = false,
    required this.createdAt,
  });

  factory Testimonial.fromRow(Map<String, dynamic> row) => Testimonial(
        id: row['id'] as String,
        name: (row['name'] as String?) ?? '',
        quote: (row['quote'] as String?) ?? '',
        rating: (row['rating'] as num?)?.toInt() ?? 5,
        isApproved: (row['is_approved'] as bool?) ?? false,
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
