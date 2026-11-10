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
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: products.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: .63,
    ),
    itemBuilder: (context, index) {
      final product = products[index];
      final saved = wishlist.contains(product.id);
      return GestureDetector(
        onTap: () => onOpenProduct(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: StoreProductImage(
                      product: product,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleIconButton(
                      icon: saved ? Icons.favorite : Icons.favorite_border,
                      onPressed: () => onWishlist(product.id),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.categoryLabel,
              style: const TextStyle(
                color: StoreColors.muted,
                fontSize: 9,
                letterSpacing: .8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onOpenProduct(product),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                ),
              ],
            ),
          ],
        ),
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
