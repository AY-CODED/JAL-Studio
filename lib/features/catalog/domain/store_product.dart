import '../../../core/utils/currency.dart';

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.brand,
    required this.priceKobo,
    required this.imageUrl,
    required this.stock,
    this.sizes = const [],
    this.colors = const [],
    this.styles = const [],
    this.rating = 0,
    this.reviewCount = 0,
  });

  factory StoreProduct.fromJson(
    Map<String, dynamic> json, {
    required Uri imageOrigin,
  }) {
    final imagePath = json['imageUrl'] as String?;
    return StoreProduct(
      id: json['_id'] as String? ?? json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String? ?? '',
      priceKobo: json['priceKobo'] as int,
      imageUrl: imagePath == null ? null : imageOrigin.resolve(imagePath),
      stock: json['stock'] as int? ?? 0,
      sizes: (json['sizes'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(growable: false),
      colors: (json['colors'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(growable: false),
      styles: (json['styles'] as List<dynamic>? ?? const [])
          .cast<String>()
          .toList(growable: false),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  final String id;
  final String slug;
  final String name;
  final String category;
  final String brand;
  final int priceKobo;
  final Uri? imageUrl;
  final int stock;
  final List<String> sizes;
  final List<String> colors;
  final List<String> styles;
  final double rating;
  final int reviewCount;

  String get price {
    return formatNaira(priceKobo);
  }

  String get categoryLabel => switch (category) {
    'menswear' => "MEN'S WEAR",
    'womenswear' => "WOMEN'S WEAR",
    'accessories' => 'ACCESSORIES',
    'activewear' => 'ACTIVEWEAR',
    _ => category.toUpperCase(),
  };
}

const sampleStoreProducts = [
  StoreProduct(
    id: 'sample-blazer',
    slug: 'stitched-leather-silk-blazer',
    name: 'Stitched Leather Silk Blazer',
    category: 'menswear',
    brand: 'Atelier Urbanett',
    priceKobo: 7000000,
    imageUrl: null,
    stock: 12,
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
  ),
  StoreProduct(
    id: 'sample-suit',
    slug: 'linen-blend-suit',
    name: 'Linen Blend Suit',
    category: 'menswear',
    brand: 'Atelier Urbanett',
    priceKobo: 9500000,
    imageUrl: null,
    stock: 8,
  ),
];
