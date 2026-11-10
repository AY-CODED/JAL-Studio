import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/store_product.dart';

class CatalogQuery {
  const CatalogQuery({
    this.search = '',
    this.category,
    this.brand,
    this.size,
    this.color,
    this.style,
    this.minPriceKobo,
    this.maxPriceKobo,
    this.sort = 'recommended',
  });

  final String search;
  final String? category;
  final String? brand;
  final String? size;
  final String? color;
  final String? style;
  final int? minPriceKobo;
  final int? maxPriceKobo;
  final String sort;

  bool get isDefault =>
      search.isEmpty &&
      category == null &&
      brand == null &&
      size == null &&
      color == null &&
      style == null &&
      minPriceKobo == null &&
      maxPriceKobo == null &&
      sort == 'recommended';

  Map<String, Object> get parameters => {
    'limit': 50,
    'sort': sort,
    if (search.isNotEmpty) 'search': search,
    'category': ?category,
    'brand': ?brand,
    'size': ?size,
    'color': ?color,
    'style': ?style,
    'minPriceKobo': ?minPriceKobo,
    'maxPriceKobo': ?maxPriceKobo,
  };

  @override
  bool operator ==(Object other) =>
      other is CatalogQuery &&
      other.search == search &&
      other.category == category &&
      other.brand == brand &&
      other.size == size &&
      other.color == color &&
      other.style == style &&
      other.minPriceKobo == minPriceKobo &&
      other.maxPriceKobo == maxPriceKobo &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    search,
    category,
    brand,
    size,
    color,
    style,
    minPriceKobo,
    maxPriceKobo,
    sort,
  );
}

class CatalogRepository {
  const CatalogRepository(this.client);
  final ApiClient client;

  Future<List<StoreProduct>> getProducts({
    CatalogQuery query = const CatalogQuery(),
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: query.parameters,
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map(
          (item) => StoreProduct.fromJson(
            item as Map<String, dynamic>,
            imageOrigin: ApiConfig.origin,
          ),
        )
        .toList(growable: false);
  }

  Future<StoreProduct> getProduct(String idOrSlug) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/products/$idOrSlug',
    );
    return StoreProduct.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      imageOrigin: ApiConfig.origin,
    );
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(apiClientProvider)),
);

final catalogProductsProvider = FutureProvider<List<StoreProduct>>(
  (ref) => ref.watch(catalogRepositoryProvider).getProducts(),
);

final catalogSearchProvider =
    FutureProvider.family<List<StoreProduct>, CatalogQuery>(
      (ref, query) =>
          ref.watch(catalogRepositoryProvider).getProducts(query: query),
    );
