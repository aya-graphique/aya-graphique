enum ProductCategory {
  classic,
  dotted,
  planner,
  kraft,
  premium,
  kids;

  String get label {
    switch (this) {
      case ProductCategory.classic:
        return 'Classic Ruled';
      case ProductCategory.dotted:
        return 'Dot Grid';
      case ProductCategory.planner:
        return 'Planners';
      case ProductCategory.kraft:
        return 'Kraft & Recycled';
      case ProductCategory.premium:
        return 'Premium Leather';
      case ProductCategory.kids:
        return 'Kids & Sketch';
    }
  }
}
