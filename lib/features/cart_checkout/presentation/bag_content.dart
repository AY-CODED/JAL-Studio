import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../../../core/utils/currency.dart';
import '../domain/store_cart.dart';
import '../../catalog/presentation/catalog_widgets.dart';

class BagContent extends StatelessWidget {
  const BagContent({
    super.key,
    required this.cart,
    required this.isSignedIn,
    required this.onContinueShopping,
    required this.onSignIn,
    required this.onCheckout,
  });

  final StoreCart cart;
  final bool isSignedIn;
  final VoidCallback onContinueShopping;
  final VoidCallback onSignIn;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    if (cart.itemCount == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: StoreColors.oliveWash,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 30,
                color: StoreColors.olive,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your bag is waiting',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Discover pieces made for you.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: StoreColors.muted),
            ),
            const SizedBox(height: 20),
            if (!isSignedIn)
              OutlinedButton(
                onPressed: onSignIn,
                child: const Text('Sign in to view your saved bag'),
              ),
            FilledButton(
              onPressed: onContinueShopping,
              child: const Text('Continue shopping'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your bag', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            '${cart.itemCount} ${cart.itemCount == 1 ? 'piece' : 'pieces'} selected for you',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: SizedBox(
                              width: 74,
                              height: 88,
                              child: StoreProductImage(
                                product: item.product,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.brand.isEmpty
                                      ? item.product.categoryLabel
                                      : item.product.brand.toUpperCase(),
                                  style: const TextStyle(
                                    color: StoreColors.muted,
                                    fontSize: 9,
                                    letterSpacing: .9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  [
                                    if (item.color != null) item.color!,
                                    if (item.size != null) 'Size ${item.size}',
                                    'Qty ${item.quantity}',
                                  ].join(' · '),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatNaira(item.lineTotalKobo),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        formatNaira(cart.subtotalKobo),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Delivery and final total are calculated at checkout.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onCheckout,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Proceed to checkout'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
