import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/store_colors.dart';
import '../data/catalog_repository.dart';
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

class ShopContent extends ConsumerStatefulWidget {
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
  ConsumerState<ShopContent> createState() => _ShopContentState();
}

class _ShopContentState extends ConsumerState<ShopContent> {
  String _category = 'All';
  String _searchText = '';
  String _search = '';
  String? _brand;
  String? _size;
  String? _color;
  String? _style;
  int? _minPriceKobo;
  int? _maxPriceKobo;
  String _sort = 'recommended';
  Timer? _searchTimer;

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryCode = switch (_category) {
      'Men' => 'menswear',
      'Women' => 'womenswear',
      'Accessories' => 'accessories',
      'Activewear' => 'activewear',
      _ => null,
    };
    final query = CatalogQuery(
      search: _search,
      category: categoryCode,
      brand: _brand,
      size: _size,
      color: _color,
      style: _style,
      minPriceKobo: _minPriceKobo,
      maxPriceKobo: _maxPriceKobo,
      sort: _sort,
    );
    final products = query.isDefault
        ? AsyncValue<List<StoreProduct>>.data(widget.products)
        : ref.watch(catalogSearchProvider(query));
    return products.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load matching products.'),
            TextButton(
              onPressed: () => ref.invalidate(catalogSearchProvider(query)),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
      data: (visibleProducts) => SingleChildScrollView(
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
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search products, brands, styles',
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchTimer?.cancel();
                          setState(() {
                            _searchText = '';
                            _search = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchText = value;
                _searchTimer?.cancel();
                _searchTimer = Timer(const Duration(milliseconds: 350), () {
                  if (mounted) setState(() => _search = _searchText.trim());
                });
                setState(() {});
              },
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
                  style: const TextStyle(
                    color: StoreColors.muted,
                    fontSize: 12,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final maximumPrice = widget.products.fold<int>(
                      1,
                      (maximum, product) => product.priceKobo > maximum
                          ? product.priceKobo
                          : maximum,
                    );
                    final selected = await showModalBottomSheet<CatalogQuery>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: StoreColors.paper,
                      builder: (_) => FilterSortSheet(
                        initial: query,
                        brands:
                            widget.products
                                .map((product) => product.brand)
                                .toSet()
                                .toList()
                              ..sort(),
                        sizes:
                            widget.products
                                .expand((product) => product.sizes)
                                .toSet()
                                .toList()
                              ..sort(),
                        colors:
                            widget.products
                                .expand((product) => product.colors)
                                .toSet()
                                .toList()
                              ..sort(),
                        styles:
                            widget.products
                                .expand((product) => product.styles)
                                .toSet()
                                .toList()
                              ..sort(),
                        maximumPriceKobo: maximumPrice,
                      ),
                    );
                    if (selected == null || !mounted) return;
                    setState(() {
                      _category = switch (selected.category) {
                        'menswear' => 'Men',
                        'womenswear' => 'Women',
                        'accessories' => 'Accessories',
                        'activewear' => 'Activewear',
                        _ => 'All',
                      };
                      _brand = selected.brand;
                      _size = selected.size;
                      _color = selected.color;
                      _style = selected.style;
                      _minPriceKobo = selected.minPriceKobo;
                      _maxPriceKobo = selected.maxPriceKobo;
                      _sort = selected.sort;
                    });
                  },
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
