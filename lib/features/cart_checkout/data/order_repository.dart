import 'dart:math';

import 'package:dio/dio.dart';
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

class PaystackRedirect {
  const PaystackRedirect({
    required this.orderId,
    required this.orderNumber,
    required this.reference,
    required this.authorizationUrl,
  });

  factory PaystackRedirect.fromJson(Map<String, dynamic> json) =>
      PaystackRedirect(
        orderId: json['orderId'] as String,
        orderNumber: json['orderNumber'] as String,
        reference: json['reference'] as String,
        authorizationUrl: Uri.parse(json['authorizationUrl'] as String),
      );

  final String orderId;
  final String orderNumber;
  final String reference;
  final Uri authorizationUrl;
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalKobo,
    required this.createdAt,
    required this.itemCount,
    required this.items,
    required this.hasPaymentSession,
    this.returnStatus,
  });

  factory StoreOrder.fromJson(Map<String, dynamic> json) => StoreOrder(
    id: json['_id'] as String,
    orderNumber: json['orderNumber'] as String,
    status: json['status'] as String,
    totalKobo: json['totalKobo'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    itemCount: (json['items'] as List<dynamic>).fold<int>(
      0,
      (count, item) => count + (item['quantity'] as int),
    ),
    hasPaymentSession: json['paymentReference'] != null,
    items: (json['items'] as List<dynamic>)
        .map((item) => StoreOrderItem.fromJson(item as Map<String, dynamic>))
        .toList(growable: false),
    returnStatus:
        (json['returnRequest'] as Map<String, dynamic>?)?['status'] as String?,
  );

  final String id;
  final String orderNumber;
  final String status;
  final int totalKobo;
  final DateTime createdAt;
  final int itemCount;
  final List<StoreOrderItem> items;
  final bool hasPaymentSession;
  final String? returnStatus;
}

class StoreOrderItem {
  const StoreOrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
  });

  factory StoreOrderItem.fromJson(Map<String, dynamic> json) => StoreOrderItem(
    productId: json['product'] as String,
    name: json['name'] as String,
    quantity: json['quantity'] as int,
  );

  final String productId;
  final String name;
  final int quantity;
}

class OrderRepository {
  const OrderRepository(this.client);
  final ApiClient client;

  Future<bool> getPaystackEnabled() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/payments/config',
    );
    return response.data!['data']['paystackEnabled'] as bool;
  }

  Future<PendingOrder> createOrder({
    required String addressId,
    required String idempotencyKey,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/orders',
      data: {'addressId': addressId},
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final order = data['order'] as Map<String, dynamic>;
    final payment = data['payment'] as Map<String, dynamic>;
    return PendingOrder.fromJson({
      ...order,
      'paymentMessage': payment['message'],
    });
  }

  Future<PaystackRedirect> startPaystack(String orderId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/orders/$orderId/paystack',
    );
    return PaystackRedirect.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  }

  Future<String> verifyPayment(String orderId) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/orders/$orderId/verify-payment',
    );
    return response.data!['data']['status'] as String;
  }

  Future<List<StoreOrder>> getOrders() async {
    final response = await client.dio.get<Map<String, dynamic>>('/orders');
    return (response.data!['data'] as List<dynamic>)
        .map((item) => StoreOrder.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> requestCancellation(String orderId, String reason) async {
    await client.dio.post<void>(
      '/orders/$orderId/cancellation',
      data: {'reason': reason},
    );
  }

  Future<void> requestReturn(String orderId, String reason) async {
    await client.dio.post<void>(
      '/orders/$orderId/return-request',
      data: {'reason': reason},
    );
  }

  Future<void> requestReview({
    required String productId,
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    await client.dio.post<void>(
      '/products/$productId/reviews',
      data: {'orderId': orderId, 'rating': rating, 'comment': comment},
    );
  }

  String newIdempotencyKey() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }
}

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);

final paystackEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(orderRepositoryProvider).getPaystackEnabled(),
);

final ordersProvider = FutureProvider<List<StoreOrder>>(
  (ref) => ref.watch(orderRepositoryProvider).getOrders(),
);
