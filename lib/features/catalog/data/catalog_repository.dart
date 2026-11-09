import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/store_product.dart';

class CatalogRepository {
  const CatalogRepository(this.client);
  final ApiClient client;

  Future<List<StoreProduct>> getProducts({String? category}) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'limit': 50, 'category': ?category},
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
