import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../catalog/domain/store_product.dart';

class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.isDefault,
    this.postalCode,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        id: json['_id'] as String,
        label: json['label'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        street: json['street'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        isDefault: json['isDefault'] as bool? ?? false,
        postalCode: json['postalCode'] as String?,
      );

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String? postalCode;
  final bool isDefault;

  String get oneLineAddress => '$street, $city, $state';
}

class AccountRepository {
  const AccountRepository(this.client);
  final ApiClient client;

  Future<List<DeliveryAddress>> getAddresses() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/account/addresses',
    );
    return (response.data!['data'] as List<dynamic>)
        .map((item) => DeliveryAddress.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> addAddress(Map<String, Object?> address) async {
    await client.dio.post<Map<String, dynamic>>(
      '/account/addresses',
      data: address,
    );
  }

  Future<void> removeAddress(String id) async {
    await client.dio.delete<void>('/account/addresses/$id');
  }

  Future<void> setDefaultAddress(String id) async {
    await client.dio.patch<Map<String, dynamic>>(
      '/account/addresses/$id',
      data: {'isDefault': true},
    );
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, Object?> profile,
  ) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '/account/me',
      data: profile,
    );
    return response.data!['data']['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getNotifications() async {
    final response = await client.dio.get<Map<String, dynamic>>('/account/me');
    return response.data!['data']['user']['notifications']
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await client.dio.get<Map<String, dynamic>>('/account/me');
    return response.data!['data']['user'] as Map<String, dynamic>;
  }

  Future<List<StoreProduct>> getWishlist() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/account/wishlist',
    );
    return (response.data!['data'] as List<dynamic>)
        .map(
          (item) => StoreProduct.fromJson(
            item as Map<String, dynamic>,
            imageOrigin: ApiConfig.origin,
          ),
        )
        .toList(growable: false);
  }

  Future<void> addToWishlist(String productId) async {
    await client.dio.post<void>('/account/wishlist/$productId');
  }

  Future<void> removeFromWishlist(String productId) async {
    await client.dio.delete<void>('/account/wishlist/$productId');
  }
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(apiClientProvider)),
);

final addressesProvider = FutureProvider<List<DeliveryAddress>>((ref) async {
  await ref.watch(authProvider.future);
  return ref.watch(accountRepositoryProvider).getAddresses();
});

final profileNotificationsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  await ref.watch(authProvider.future);
  return ref.watch(accountRepositoryProvider).getNotifications();
});

final accountProfileProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  await ref.watch(authProvider.future);
  return ref.watch(accountRepositoryProvider).getProfile();
});

final wishlistProvider = FutureProvider<List<StoreProduct>>((ref) async {
  final user = await ref.watch(authProvider.future);
  if (user == null) return const [];
  return ref.watch(accountRepositoryProvider).getWishlist();
});
