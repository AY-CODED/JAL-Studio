import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../domain/store_product.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    this.selected = 'All',
    this.onSelected,
  });
  final List<String> categories;
  final String selected;
  final ValueChanged<String>? onSelected;

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  late String _selected = widget.selected;

  @override
  void didUpdateWidget(covariant CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: widget.categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = widget.categories[index];
        final isSelected = _selected == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) {
            setState(() => _selected = category);
            widget.onSelected?.call(category);
          },
          selectedColor: StoreColors.ink,
          backgroundColor: StoreColors.paper,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : StoreColors.ink,
            fontSize: 12,
          ),
          side: BorderSide(
            color: isSelected ? StoreColors.ink : StoreColors.line,
          ),
          shape: const StadiumBorder(),
          showCheckmark: false,
        );
      },
    ),
  );
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({
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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 940
          ? 4
          : constraints.maxWidth >= 600
          ? 3
          : 2;
      final ratio = columns == 2 ? .64 : .74;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: ratio,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          final saved = wishlist.contains(product.id);
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onOpenProduct(product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        StoreProductImage(product: product, fit: BoxFit.cover),
                        Positioned(
                          top: 9,
                          right: 9,
                          child: CircleIconButton(
                            icon: saved
                                ? Icons.favorite
                                : Icons.favorite_border,
                            onPressed: () => onWishlist(product.id),
                          ),
                        ),
                        if (product.stock <= 3 && product.stock > 0)
                          Positioned(
                            left: 9,
                            bottom: 9,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: StoreColors.white.withValues(alpha: .94),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'FEW LEFT',
                                style: TextStyle(
                                  fontSize: 8,
                                  letterSpacing: .8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(11, 10, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.brand.isEmpty
                              ? product.categoryLabel
                              : product.brand.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: StoreColors.muted,
                            fontSize: 9,
                            letterSpacing: .9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_outward_rounded,
                              size: 15,
                              color: StoreColors.muted,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class StoreProductImage extends StatelessWidget {
  const StoreProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
  });

  final StoreProduct product;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    if (imageUrl == null) {
      return Image.asset(_fallbackAsset, fit: fit);
    }
    return Image.network(
      imageUrl.toString(),
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(color: StoreColors.sand);
      },
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(_fallbackAsset, fit: fit),
    );
  }

  String get _fallbackAsset {
    final index = product.slug.hashCode.abs() % 4 + 1;
    return 'assets/images/banner$index.jpg';
  }
}
