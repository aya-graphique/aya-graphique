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
  final List<String> tags;
  final double rating;
  final int stock;
  final int sortOrder;
  // How many units of this product have actually sold, summed from every
  // order line ever placed for it — incremented atomically at checkout via
  // the `increment_product_sales` Postgres function. Powers the "Best
  // sellers" section on the storefront; never set from the admin form.
  final int salesCount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.tags = const [],
    this.rating = 4.8,
    this.stock = 25,
    this.sortOrder = 0,
    this.salesCount = 0,
  });

  bool get inStock => stock > 0;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String? ?? 'Uncategorized',
      imageUrl: map['image_url'] as String? ?? '',
      tags: (map['tags'] as List?)?.map((t) => t.toString()).toList() ?? const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      salesCount: (map['sales_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image_url': imageUrl,
        'tags': tags,
        'rating': rating,
        'stock': stock,
        'sort_order': sortOrder,
      };

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    List<String>? tags,
    double? rating,
    int? stock,
    int? sortOrder,
    int? salesCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      sortOrder: sortOrder ?? this.sortOrder,
      salesCount: salesCount ?? this.salesCount,
    );
  }
}
