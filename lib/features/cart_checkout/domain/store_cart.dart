import '../../catalog/domain/store_product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    required this.lineTotalKobo,
    this.size,
    this.color,
  });

  factory CartItem.fromJson(
    Map<String, dynamic> json, {
    required Uri imageOrigin,
  }) {
    return CartItem(
      product: StoreProduct.fromJson(
        json['product'] as Map<String, dynamic>,
        imageOrigin: imageOrigin,
      ),
      quantity: json['quantity'] as int,
      lineTotalKobo: json['lineTotalKobo'] as int,
      size: json['size'] as String?,
      color: json['color'] as String?,
    );
  }

  final StoreProduct product;
  final int quantity;
  final int lineTotalKobo;
  final String? size;
  final String? color;
}

class StoreCart {
  const StoreCart({
    required this.items,
    required this.itemCount,
    required this.subtotalKobo,
  });

  const StoreCart.empty() : items = const [], itemCount = 0, subtotalKobo = 0;

  factory StoreCart.fromJson(
    Map<String, dynamic> json, {
    required Uri imageOrigin,
  }) {
    final items = (json['items'] as List<dynamic>)
        .map(
          (item) => CartItem.fromJson(
            item as Map<String, dynamic>,
            imageOrigin: imageOrigin,
          ),
        )
        .toList(growable: false);
    return StoreCart(
      items: items,
      itemCount: json['itemCount'] as int,
      subtotalKobo: json['subtotalKobo'] as int,
    );
  }

  final List<CartItem> items;
  final int itemCount;
  final int subtotalKobo;
}
