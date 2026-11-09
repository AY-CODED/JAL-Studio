import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/store_cart.dart';

class CartRepository {
  const CartRepository(this.client);
  final ApiClient client;

  Future<StoreCart> getCart() async {
    final response = await client.dio.get<Map<String, dynamic>>('/cart');
    return StoreCart.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      imageOrigin: ApiConfig.origin,
    );
  }

  Future<StoreCart> addItem({
    required String productId,
    required int quantity,
    required String size,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/cart/items',
      data: {
        'productId': productId,
        'quantity': quantity,
        if (size.isNotEmpty) 'size': size,
      },
    );
    return StoreCart.fromJson(
      response.data!['data'] as Map<String, dynamic>,
      imageOrigin: ApiConfig.origin,
    );
  }
}

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(ref.watch(apiClientProvider)),
);

final cartProvider = FutureProvider<StoreCart>((ref) async {
  final user = await ref.watch(authProvider.future);
  if (user == null) return const StoreCart.empty();
  return ref.watch(cartRepositoryProvider).getCart();
});
