import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../domain/store_product.dart';
import 'catalog_widgets.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.onAddToBag,
    required this.isWishlisted,
    required this.onWishlist,
  });
  final StoreProduct product;
  final Future<void> Function(StoreProduct product, String size) onAddToBag;
  final bool isWishlisted;
  final VoidCallback onWishlist;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String _size = 'M';
  late bool _isWishlisted = widget.isWishlisted;
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'E K Ō',
    actions: [
      IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.shopping_cart_outlined),
      ),
    ],
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 390,
                    child: StoreProductImage(
                      product: widget.product,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleIconButton(
                    icon: _isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onPressed: () {
                      widget.onWishlist();
                      setState(() => _isWishlisted = !_isWishlisted);
                    },
                  ),
                ),
                const Positioned(
                  left: 12,
                  bottom: 12,
                  child: Chip(
                    label: Text('1 / 5'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 78,
                      height: 70,
                      child: StoreProductImage(
                        product: widget.product,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StoreEyebrow('ATELIER URBANETT'),
                const SizedBox(height: 6),
                Text(
                  widget.product.name,
                  style: const TextStyle(fontSize: 23, fontFamily: 'serif'),
                ),
                Text(
                  widget.product.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '★  4.8  (124 reviews)     ·     ● In Stock',
                  style: TextStyle(fontSize: 12, color: StoreColors.muted),
                ),
                const SizedBox(height: 18),
                const Text('Color', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    ColorDot(color: Color(0xFF243957), selected: true),
                    ColorDot(color: Colors.black),
                    ColorDot(color: Color(0xFFCABC9D)),
                    ColorDot(color: Color(0xFFB7B9B8)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Size', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['S', 'M', 'L', 'XL', 'XXL']
                      .map(
                        (size) => ChoiceChip(
                          label: Text(size),
                          selected: _size == size,
                          onSelected: (_) => setState(() => _size = size),
                          selectedColor: StoreColors.sand,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: StoreColors.line),
                        ),
                      )
                      .toList(),
                ),
                const Divider(height: 30),
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'VISA     Mastercard     Verve      Pay     Paystack',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                const Text(
                  '✓ Secure payment   ·   Fast delivery   ·   7-day return policy',
                  style: TextStyle(fontSize: 10, color: StoreColors.muted),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await widget.onAddToBag(widget.product, _size);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to your bag')),
                      );
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('ADD TO BAG'),
                    style: FilledButton.styleFrom(
                      backgroundColor: StoreColors.ink,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
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
