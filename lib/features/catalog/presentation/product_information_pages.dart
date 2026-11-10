import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../domain/store_product.dart';

final productReviewsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      productId,
    ) async {
      final response = await ref
          .watch(apiClientProvider)
          .dio
          .get<Map<String, dynamic>>('/products/$productId/reviews');
      return (response.data!['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
    });

class ProductReviewsPage extends ConsumerWidget {
  const ProductReviewsPage({super.key, required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context, WidgetRef ref) => StorePageScaffold(
    title: 'Customer Reviews',
    child: ref
        .watch(productReviewsProvider(product.id))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(apiErrorMessage(error)),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(productReviewsProvider(product.id)),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
          data: (reviews) => reviews.isEmpty
              ? const Center(child: Text('No verified customer reviews yet.'))
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontFamily: 'serif', fontSize: 24),
                    ),
                    Text(
                      '${product.rating.toStringAsFixed(1)} ★ · ${reviews.length} review(s)',
                    ),
                    const SizedBox(height: 16),
                    ...reviews.map((review) {
                      final reviewer = review['user'] as Map<String, dynamic>?;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${review['rating']} ★ · ${reviewer?['fullName'] ?? 'Verified customer'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(review['comment'] as String),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
        ),
  );
}

class SizeGuidePage extends StatelessWidget {
  const SizeGuidePage({super.key, required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    final sizes = product.sizes.isEmpty
        ? const ['S', 'M', 'L', 'XL', 'XXL']
        : product.sizes;
    return StorePageScaffold(
      title: 'Size Guide',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PageIntro(
            icon: Icons.straighten,
            title: 'Find your fit',
            subtitle:
                'Use your body measurements and each atelier’s size chart.',
          ),
          const Text(
            'Measure around the fullest part of your chest, waist, and hips. '
            'If you are between sizes, choose the larger size for a relaxed fit.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 18),
          const Text(
            'AVAILABLE SIZES',
            style: TextStyle(
              color: StoreColors.muted,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: sizes.map((size) => Chip(label: Text(size))).toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            'The product-specific measurements should be confirmed with the seller before purchase.',
            style: TextStyle(color: StoreColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
