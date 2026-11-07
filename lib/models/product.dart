/// A notebook for sale. Mirrors a row in the `products` Supabase table.
///
/// `category` is a plain string, not a fixed enum — the admin dashboard lets
/// you create brand new categories on the fly, and the storefront's filter
/// chips are built from whatever category names actually exist on your
/// products.
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  // Up to 6 extra optional gallery photos (Photos 2–7), shown alongside
  // imageUrl on the product detail page. Blank entries mean "not set" — the
  // gallery just skips them instead of showing a broken image.
  final List<String> extraImages;
  static const int maxPhotos = 7;
  final List<String> tags;
  final double rating;
  final int stock;
  final int sortOrder;
  // How many units of this product have actually sold, summed from every
  // order line ever placed for it — incremented atomically at checkout via
  // the `increment_product_sales` Postgres function. Powers the "Best
  // sellers" section on the storefront; never set from the admin form.
  final int salesCount;
  // Owner-set discount, 0–100. 0 (the default) means no discount — the
  // product just sells at `price`. Anything above 0 knocks that percentage
  // off `price` everywhere the product's price is shown or charged (see
  // [discountedPrice]).
  final double discountPercent;
  // When this row was first created in Supabase (the table's default
  // `created_at` timestamp). Null when the source map doesn't include it
  // (e.g. rows built by hand in sample_products.dart) — [isNew] just
  // treats that as "not new" instead of throwing.
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.extraImages = const [],
    this.tags = const [],
    this.rating = 4.8,
    this.stock = 25,
    this.sortOrder = 0,
    this.salesCount = 0,
    this.discountPercent = 0,
    this.createdAt,
  });

  bool get inStock => stock > 0;

  // "Just arrived" badge — true for the first 14 days after the product
  // was added from the admin dashboard. Purely presentational (never
  // affects sorting/filtering), and simply never true for products with
  // no [createdAt] (e.g. the bundled sample catalog).
  static const _newWindow = Duration(days: 14);
  bool get isNew =>
      createdAt != null && DateTime.now().difference(createdAt!) <= _newWindow;

  bool get hasDiscount => discountPercent > 0;

  /// Every non-empty gallery photo, in order (imageUrl, then extraImages).
  /// Blank slots (up to [maxPhotos] total) are simply skipped — the detail
  /// page's gallery only ever shows photos that actually exist.
  List<String> get galleryImages =>
      [imageUrl, ...extraImages].where((u) => u.trim().isNotEmpty).take(maxPhotos).toList();

  /// The price a shopper actually pays — `price` minus `discountPercent`,
  /// or plain `price` when there's no discount. This is what every screen
  /// should show/charge; `price` alone is just the pre-discount reference
  /// (shown struck through next to it when discounted).
  double get discountedPrice =>
      hasDiscount ? price - (price * discountPercent / 100) : price;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String? ?? 'Uncategorized',
      imageUrl: map['image_url'] as String? ?? '',
      extraImages: [
        for (var i = 2; i <= maxPhotos; i++) map['image_url_$i'] as String? ?? '',
      ],
      tags: (map['tags'] as List?)?.map((t) => t.toString()).toList() ?? const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      salesCount: (map['sales_count'] as num?)?.toInt() ?? 0,
      discountPercent: (map['discount_percent'] as num?)?.toDouble() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        for (var i = 2; i <= maxPhotos; i++)
          'image_url_$i': i - 2 < extraImages.length ? extraImages[i - 2] : '',
        'tags': tags,
        'rating': rating,
        'stock': stock,
        'sort_order': sortOrder,
        'discount_percent': discountPercent,
      };

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    List<String>? extraImages,
    List<String>? tags,
    double? rating,
    int? stock,
    int? sortOrder,
    int? salesCount,
    double? discountPercent,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      extraImages: extraImages ?? this.extraImages,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      sortOrder: sortOrder ?? this.sortOrder,
      salesCount: salesCount ?? this.salesCount,
      discountPercent: discountPercent ?? this.discountPercent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
