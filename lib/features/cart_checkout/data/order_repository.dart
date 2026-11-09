import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class PendingOrder {
  const PendingOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalKobo,
    required this.paymentMessage,
  });

  factory PendingOrder.fromJson(Map<String, dynamic> json) => PendingOrder(
    id: json['_id'] as String,
    orderNumber: json['orderNumber'] as String,
    status: json['status'] as String,
    totalKobo: json['totalKobo'] as int,
    paymentMessage:
        json['paymentMessage'] as String? ?? 'Payment has not been collected.',
  );

  final String id;
  final String orderNumber;
  final String status;
  final int totalKobo;
  final String paymentMessage;
}

class OrderRepository {
  const OrderRepository(this.client);
  final ApiClient client;

  Future<PendingOrder> createOrder({
    required String addressId,
    required String paymentProvider,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/orders',
      data: {'addressId': addressId, 'paymentProvider': paymentProvider},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final order = data['order'] as Map<String, dynamic>;
    final payment = data['payment'] as Map<String, dynamic>;
    return PendingOrder.fromJson({
      ...order,
      'paymentMessage': payment['message'],
    });
  }
}

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);
