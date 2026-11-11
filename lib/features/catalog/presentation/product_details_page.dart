import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../domain/store_product.dart';
import 'catalog_widgets.dart';
import 'product_information_pages.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.onAddToBag,
    required this.isWishlisted,
    required this.onWishlist,
  });
  final StoreProduct product;
  final Future<void> Function(StoreProduct product, String size, String? color)
  onAddToBag;
  final bool isWishlisted;
  final VoidCallback onWishlist;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String _size = 'M';
  String? _color;
  late bool _isWishlisted = widget.isWishlisted;

  @override
  void initState() {
    super.initState();
    _size = widget.product.sizes.isEmpty
        ? 'One size'
        : widget.product.sizes.first;
    _color = widget.product.colors.isEmpty ? null : widget.product.colors.first;
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Product details',
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: _productImage()),
                const SizedBox(width: 40),
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: _productDetails(context),
                  ),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _productImage(),
              const SizedBox(height: 22),
              _productDetails(context),
            ],
          );
        },
      ),
    ),
  );

  Widget _productImage() => AspectRatio(
    aspectRatio: .86,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: StoreProductImage(product: widget.product, fit: BoxFit.cover),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: CircleIconButton(
            icon: _isWishlisted ? Icons.favorite : Icons.favorite_border,
            onPressed: () {
              widget.onWishlist();
              setState(() => _isWishlisted = !_isWishlisted);
            },
          ),
        ),
      ],
    ),
  );

  Widget _productDetails(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      StoreEyebrow(
        widget.product.brand.isEmpty
            ? widget.product.categoryLabel
            : widget.product.brand.toUpperCase(),
      ),
      const SizedBox(height: 8),
      Text(
        widget.product.name,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 8),
      Text(
        widget.product.price,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
      ),
      const SizedBox(height: 12),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          if (widget.product.reviewCount > 0) ...[
            Text(
              '★  ${widget.product.rating.toStringAsFixed(1)}',
              style: const TextStyle(
                color: StoreColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '(${widget.product.reviewCount} reviews)',
              style: const TextStyle(color: StoreColors.muted, fontSize: 12),
            ),
          ] else
            const Text(
              'No reviews yet',
              style: TextStyle(color: StoreColors.muted, fontSize: 12),
            ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ProductReviewsPage(product: widget.product),
              ),
            ),
            child: const Text('Read reviews'),
          ),
        ],
      ),
      const SizedBox(height: 22),
      const Text('Colour', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.product.colors.isEmpty
            ? [
                Text(
                  'See product photos for available colours.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ]
            : widget.product.colors
                  .map(
                    (color) => ChoiceChip(
                      label: Text(color),
                      selected: _color == color,
                      onSelected: (_) => setState(() => _color = color),
                    ),
                  )
                  .toList(),
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Size', style: TextStyle(fontWeight: FontWeight.w600)),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => SizeGuidePage(product: widget.product),
              ),
            ),
            child: const Text('Size guide'),
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            (widget.product.sizes.isEmpty
                    ? const ['One size']
                    : widget.product.sizes)
                .map(
                  (size) => ChoiceChip(
                    label: Text(size),
                    selected: _size == size,
                    onSelected: (_) => setState(() => _size = size),
                  ),
                )
                .toList(),
      ),
      const SizedBox(height: 22),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline_rounded, color: StoreColors.olive),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secure checkout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Payment is completed through Paystack and verified before your order is confirmed.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: widget.product.stock <= 0
              ? null
              : () async {
                  await widget.onAddToBag(widget.product, _size, _color);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to your bag')),
                  );
                },
          icon: const Icon(Icons.shopping_bag_outlined),
          label: Text(
            widget.product.stock <= 0 ? 'OUT OF STOCK' : 'ADD TO BAG',
          ),
        ),
      ),
    ],
  );
}

class ColorDot extends StatelessWidget {
  const ColorDot({super.key, required this.color, this.selected = false});
  final Color color;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 10),
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? StoreColors.ink : Colors.transparent,
      ),
    ),
    child: CircleAvatar(radius: 11, backgroundColor: color),
  );
}
