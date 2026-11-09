import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../domain/store_product.dart';
import 'catalog_widgets.dart';
import 'filter_sort_sheet.dart';

class StoreHomeContent extends StatelessWidget {
  const StoreHomeContent({
    super.key,
    required this.products,
    required this.wishlist,
    required this.onWishlist,
    required this.onOpenProduct,
    required this.onShop,
  });

  final List<StoreProduct> products;
  final Set<String> wishlist;
  final ValueChanged<String> onWishlist;
  final ValueChanged<StoreProduct> onOpenProduct;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 230,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/banner1.jpg', fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black26, Colors.black87],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'NEW COLLECTION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Timeless Elegance\nStarts Here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.15,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Modern styles. Classic vibes.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onShop,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Shop now  →'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const CategoryChips(
          categories: ['All', 'Men', 'Women', 'Accessories', 'Activewear'],
        ),
        const SizedBox(height: 16),
        ProductGrid(
          products: products,
          wishlist: wishlist,
          onWishlist: onWishlist,
          onOpenProduct: onOpenProduct,
        ),
      ],
    ),
  );
}

class ShopContent extends StatefulWidget {
  const ShopContent({
    super.key,
    required this.products,
    required this.wishlist,
    required this.onWishlist,
    required this.onOpenProduct,
  });
  final List<StoreProduct> products;
  final Set<String> wishlist;
  final ValueChanged<String> onWishlist;
  final ValueChanged<StoreProduct> onOpenProduct;

  @override
  State<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends State<ShopContent> {
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final categoryCode = switch (_category) {
      'Men' => 'menswear',
      'Women' => 'womenswear',
      'Accessories' => 'accessories',
      'Activewear' => 'activewear',
      _ => null,
    };
    final visibleProducts = categoryCode == null
        ? widget.products
        : widget.products
              .where((product) => product.category == categoryCode)
              .toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOME  ›  ${_category.toUpperCase()}',
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              color: StoreColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _category == 'All' ? 'Shop' : '${_category}wear',
            style: const TextStyle(fontSize: 32, fontFamily: 'serif'),
          ),
          const Text(
            'Modern styles for every occasion. Find your next look.',
            style: TextStyle(color: StoreColors.muted),
          ),
          const SizedBox(height: 18),
          CategoryChips(
            categories: const [
              'All',
              'Men',
              'Women',
              'Accessories',
              'Activewear',
            ],
            selected: _category,
            onSelected: (category) => setState(() => _category = category),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${visibleProducts.length} pieces',
                style: const TextStyle(color: StoreColors.muted, fontSize: 12),
              ),
              TextButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: StoreColors.paper,
                  builder: (_) => const FilterSortSheet(),
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Filter & sort'),
                style: TextButton.styleFrom(foregroundColor: StoreColors.ink),
              ),
            ],
          ),
          ProductGrid(
            products: visibleProducts,
            wishlist: widget.wishlist,
            onWishlist: widget.onWishlist,
            onOpenProduct: widget.onOpenProduct,
          ),
        ],
      ),
    );
  }
}

class ProductCollectionPage extends StatelessWidget {
  const ProductCollectionPage({
    super.key,
    required this.title,
    required this.products,
    required this.onOpenProduct,
    required this.onWishlist,
    required this.wishlist,
    this.emptyMessage = 'There are no items here yet.',
  });
  final String title;
  final List<StoreProduct> products;
  final ValueChanged<StoreProduct> onOpenProduct;
  final ValueChanged<String> onWishlist;
  final Set<String> wishlist;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => products.isEmpty
      ? Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: StoreColors.muted),
            ),
          ),
        )
      : SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontFamily: 'serif', fontSize: 32),
              ),
              const SizedBox(height: 16),
              ProductGrid(
                products: products,
                wishlist: wishlist,
                onWishlist: onWishlist,
                onOpenProduct: onOpenProduct,
              ),
            ],
          ),
        );
}
