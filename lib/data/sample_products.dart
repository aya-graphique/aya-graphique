import '../models/product.dart';

/// Bundled placeholder catalog — shown whenever Supabase isn't configured
/// yet, or while the real product list is still loading. Swap the
/// `imageUrl`s for your own product photography (or Supabase Storage URLs)
/// whenever you're ready.
final List<Product> sampleProducts = [
  const Product(
    id: 'sample-1',
    name: 'Midnight Aubergine A5',
    description:
        'Our signature ruled notebook: 192 pages of 100gsm cream paper, '
        'wrapped in a soft-touch aubergine cover with a violet foil corner.',
    price: 18.0,
    category: 'Classic Ruled',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-classic-1/800/1000',
    tags: ['bestseller', 'ruled'],
    rating: 4.9,
    stock: 42,
    sortOrder: 0,
  ),
  const Product(
    id: 'sample-2',
    name: 'Orchid Dot Grid',
    description:
        'A 5mm dot grid on bright white paper — built for bullet journaling, '
        'sketch layouts, and anything that needs a little structure.',
    price: 20.0,
    category: 'Dot Grid',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-dot-1/800/1000',
    tags: ['dot-grid', 'bujo'],
    rating: 4.8,
    stock: 30,
    sortOrder: 1,
  ),
  const Product(
    id: 'sample-3',
    name: 'Violet Pop Weekly Planner',
    description:
        'An undated 12-month weekly planner with a gradient foil edge, '
        'monthly tabs, and a ribbon marker in electric orchid.',
    price: 26.0,
    category: 'Planners',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-planner-1/800/1000',
    tags: ['planner', 'undated'],
    rating: 4.7,
    stock: 18,
    sortOrder: 2,
  ),
  const Product(
    id: 'sample-4',
    name: 'Kraft Field Notebook',
    description:
        'Pocket-sized recycled kraft cover, lay-flat binding, blank pages — '
        'the one that lives in your bag for whenever an idea shows up.',
    price: 12.0,
    category: 'Kraft & Recycled',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-kraft-1/800/1000',
    tags: ['pocket', 'recycled'],
    rating: 4.6,
    stock: 60,
    sortOrder: 3,
  ),
  const Product(
    id: 'sample-5',
    name: 'Ink Deep Leather A5',
    description:
        'Full-grain leather cover in deep aubergine, brass corner rivets, '
        'refillable with any standard A5 insert.',
    price: 58.0,
    category: 'Premium Leather',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-premium-1/800/1000',
    tags: ['leather', 'refillable'],
    rating: 5.0,
    stock: 9,
    sortOrder: 4,
  ),
  const Product(
    id: 'sample-6',
    name: 'Little Sketcher Set',
    description:
        'Three blank-page mini sketchbooks for small hands, thick paper '
        'that holds up to crayon, marker, and enthusiastic scribbling.',
    price: 15.0,
    category: 'Kids & Sketch',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-kids-1/800/1000',
    tags: ['kids', 'set-of-3'],
    rating: 4.9,
    stock: 33,
    sortOrder: 5,
  ),
  const Product(
    id: 'sample-7',
    name: 'Lilac Haze Ruled B5',
    description:
        'A larger B5 ruled notebook with a soft lilac gradient cover and '
        '160 pages of smooth, fountain-pen-friendly paper.',
    price: 22.0,
    category: 'Classic Ruled',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-classic-2/800/1000',
    tags: ['ruled', 'fountain-pen-friendly'],
    rating: 4.7,
    stock: 24,
    sortOrder: 6,
  ),
  const Product(
    id: 'sample-8',
    name: 'Amethyst Dot Journal',
    description:
        'Dot grid journal with an elastic closure, expandable back pocket, '
        'and a two-tone violet-to-orchid cover gradient.',
    price: 24.0,
    category: 'Dot Grid',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-dot-2/800/1000',
    tags: ['dot-grid', 'elastic-closure'],
    rating: 4.8,
    stock: 20,
    sortOrder: 7,
  ),
  const Product(
    id: 'sample-9',
    name: 'Daily Focus Planner',
    description:
        'A dated daily planner with hourly blocks, gratitude prompts, and a '
        'habit tracker printed in soft orchid ink.',
    price: 28.0,
    category: 'Planners',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-planner-2/800/1000',
    tags: ['planner', 'dated'],
    rating: 4.6,
    stock: 15,
    sortOrder: 8,
  ),
  const Product(
    id: 'sample-10',
    name: 'Recycled Kraft Trio',
    description:
        'Three pocket kraft notebooks in ruled, blank, and dot grid — mix '
        'and match for pocket, bag, or desk.',
    price: 16.0,
    category: 'Kraft & Recycled',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-kraft-2/800/1000',
    tags: ['set-of-3', 'recycled'],
    rating: 4.5,
    stock: 40,
    sortOrder: 9,
  ),
  const Product(
    id: 'sample-11',
    name: 'Aubergine Leather Traveler',
    description:
        "A traveler's journal cover in soft aubergine leather, with a "
        'pen loop and three interchangeable notebook inserts.',
    price: 64.0,
    category: 'Premium Leather',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-premium-2/800/1000',
    tags: ['leather', 'travelers-notebook'],
    rating: 4.9,
    stock: 7,
    sortOrder: 10,
  ),
  const Product(
    id: 'sample-12',
    name: 'Doodle Pad Jr.',
    description:
        'An oversized blank sketch pad for kids, thick 120gsm paper that '
        'resists bleed-through from markers and paint.',
    price: 13.0,
    category: 'Kids & Sketch',
    imageUrl: 'https://picsum.photos/seed/aya-graphique-kids-2/800/1000',
    tags: ['kids', 'sketch'],
    rating: 4.7,
    stock: 27,
    sortOrder: 11,
  ),
];
