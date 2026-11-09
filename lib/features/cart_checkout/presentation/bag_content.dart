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
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: StoreColors.muted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your bag is waiting',
              style: TextStyle(fontSize: 22, fontFamily: 'serif'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Discover pieces made for you.',
              style: TextStyle(color: StoreColors.muted),
            ),
            const SizedBox(height: 12),
            if (!isSignedIn)
              OutlinedButton(
                onPressed: onSignIn,
                child: const Text('Sign in to view your saved bag'),
              ),
            FilledButton(
              onPressed: onContinueShopping,
              style: FilledButton.styleFrom(backgroundColor: StoreColors.ink),
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
          const Text(
            'Your bag',
            style: TextStyle(fontFamily: 'serif', fontSize: 30),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 68,
                      height: 76,
                      child: StoreProductImage(
                        product: item.product,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text(
                    '${item.product.price}  ·  Qty ${item.quantity}',
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text(formatNaira(cart.subtotalKobo)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.ink,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Proceed to checkout'),
            ),
          ),
        ],
      ),
    );
  }
}
