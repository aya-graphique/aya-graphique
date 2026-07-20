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
  // Two extra optional gallery photos, shown alongside imageUrl on the
  // product detail page. Empty string means "not set" — the gallery just
  // skips blank slots instead of showing a broken image.
  final String imageUrl2;
  final String imageUrl3;
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

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.imageUrl2 = '',
    this.imageUrl3 = '',
    this.tags = const [],
    this.rating = 4.8,
    this.stock = 25,
    this.sortOrder = 0,
    this.salesCount = 0,
    this.discountPercent = 0,
  });

  bool get inStock => stock > 0;

  bool get hasDiscount => discountPercent > 0;

  /// Every non-empty gallery photo, in order (imageUrl, imageUrl2,
  /// imageUrl3). Whichever of the 3 slots were left blank are simply
  /// skipped — the detail page's gallery only ever shows photos that
  /// actually exist, and never renders empty/broken slides for the rest.
  List<String> get galleryImages =>
      [imageUrl, imageUrl2, imageUrl3].where((u) => u.trim().isNotEmpty).toList();

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
      imageUrl2: map['image_url_2'] as String? ?? '',
      imageUrl3: map['image_url_3'] as String? ?? '',
      tags: (map['tags'] as List?)?.map((t) => t.toString()).toList() ?? const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      salesCount: (map['sales_count'] as num?)?.toInt() ?? 0,
      discountPercent: (map['discount_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'image_url_2': imageUrl2,
        'image_url_3': imageUrl3,
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
    String? imageUrl2,
    String? imageUrl3,
    List<String>? tags,
    double? rating,
    int? stock,
    int? sortOrder,
    int? salesCount,
    double? discountPercent,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrl2: imageUrl2 ?? this.imageUrl2,
      imageUrl3: imageUrl3 ?? this.imageUrl3,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      sortOrder: sortOrder ?? this.sortOrder,
      salesCount: salesCount ?? this.salesCount,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}
