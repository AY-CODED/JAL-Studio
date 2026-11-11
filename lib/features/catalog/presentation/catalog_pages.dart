import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
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
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 680;
            return ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: wide ? 340 : 320,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/banner1.jpg',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xD9000000),
                            Color(0x85000000),
                            Color(0x10000000),
                          ],
                          stops: [0, .62, 1],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 46 : 26,
                        vertical: 28,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'THE JAL STUDIO EDIT',
                                style: TextStyle(
                                  color: Color(0xFFE9D4AD),
                                  fontSize: 10,
                                  letterSpacing: 2.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 13),
                              Text(
                                'Timeless Elegance\nStarts Here',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: wide ? 38 : 28,
                                  height: 1.12,
                                  fontFamily: 'serif',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 9),
                              const Text(
                                'Modern styles. Classic vibes.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 17),
                              FilledButton(
                                onPressed: onShop,
                                style: FilledButton.styleFrom(
                                  backgroundColor: StoreColors.white,
                                  foregroundColor: StoreColors.ink,
                                  minimumSize: const Size(140, 46),
                                ),
                                child: const Text('Explore the collection'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const StoreEyebrow('CURATED FOR YOU'),
        const SizedBox(height: 12),
        const CategoryChips(
          categories: ['All', 'Men', 'Women', 'Accessories', 'Activewear'],
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The collection',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Considered pieces from independent ateliers.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onShop, child: const Text('View all')),
          ],
        ),
        const SizedBox(height: 14),
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
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StoreEyebrow('DISCOVER YOUR NEXT LOOK'),
            const SizedBox(height: 8),
            Text(switch (_category) {
              'Men' => 'Menswear',
              'Women' => 'Womenswear',
              'Accessories' => 'Accessories',
              'Activewear' => 'Activewear',
              _ => 'Shop',
            }, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Modern styles for every occasion, selected from independent ateliers.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: StoreColors.muted),
            ),
            const SizedBox(height: 18),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Search products, brands, styles',
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchTimer?.cancel();
                          setState(() {
                            _searchText = '';
                            _search = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${visibleProducts.length} pieces',
                  style: Theme.of(context).textTheme.bodySmall,
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
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Filter & sort'),
                ),
              ],
            ),
            if (visibleProducts.isEmpty)
              const _EmptyProducts()
            else
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: StoreColors.oliveWash,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: StoreColors.olive,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: StoreColors.muted),
              ),
            ],
          ),
        )
      : SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreEyebrow(title.toUpperCase()),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 18),
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

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 44),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: StoreColors.oliveWash,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: StoreColors.olive,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No pieces found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or adjust your filters.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
