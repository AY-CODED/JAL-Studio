import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/store_components.dart';
import '../../account/data/account_repository.dart';
import '../../account/presentation/account_pages.dart';
import '../../catalog/presentation/catalog_widgets.dart';
import '../data/order_repository.dart';
import '../domain/store_cart.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key, required this.cart});

  final StoreCart cart;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  static const _deliveryKobo = 1500000;
  String _payment = 'paystack';
  String? _addressId;
  bool _isSubmitting = false;

  Future<void> _placeOrder() async {
    final addressId = _addressId;
    if (addressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a delivery address first.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final order = await ref
          .read(orderRepositoryProvider)
          .createOrder(addressId: addressId, paymentProvider: _payment);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order created'),
          content: Text(
            '${order.orderNumber} · ${order.status.replaceAll('_', ' ')}\n\n'
            '${order.paymentMessage}\n\n'
            'Total: ${formatNaira(order.totalKobo)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Checkout',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StoreEyebrow('ORDER SUMMARY'),
            const SizedBox(height: 12),
            ...widget.cart.items.map(
              (item) => Card(
                color: Colors.white,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 70,
                      child: StoreProductImage(
                        product: item.product,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    item.product.name,
                    style: const TextStyle(fontFamily: 'serif', fontSize: 14),
                  ),
                  subtitle: Text(
                    '${item.color ?? ''}  ·  ${item.size ?? 'One size'}  ·  Qty ${item.quantity}',
                    style: const TextStyle(fontSize: 10, height: 1.8),
                  ),
                  trailing: Text(
                    formatNaira(item.lineTotalKobo),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            PriceLine(
              title: 'Subtotal',
              amount: formatNaira(widget.cart.subtotalKobo),
            ),
            const PriceLine(title: 'Lagos Premium Delivery', amount: '₦15,000'),
            const Divider(height: 24),
            PriceLine(
              title: 'Total',
              amount: formatNaira(widget.cart.subtotalKobo + _deliveryKobo),
              bold: true,
            ),
            const SizedBox(height: 20),
            const StoreEyebrow('DELIVERY ADDRESS'),
            const SizedBox(height: 8),
            ref
                .watch(addressesProvider)
                .when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add an address before placing your order.',
                            style: TextStyle(color: StoreColors.muted),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const DeliveryAddressesPage(),
                              ),
                            ).then((_) => ref.invalidate(addressesProvider)),
                            child: const Text('Manage delivery addresses'),
                          ),
                        ],
                      );
                    }
                    final selected =
                        addresses.any((address) => address.id == _addressId)
                        ? _addressId
                        : addresses
                              .firstWhere(
                                (address) => address.isDefault,
                                orElse: () => addresses.first,
                              )
                              .id;
                    _addressId = selected;
                    return DropdownButtonFormField<String>(
                      initialValue: selected,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: addresses
                          .map(
                            (address) => DropdownMenuItem(
                              value: address.id,
                              child: Text(
                                '${address.label} · ${address.oneLineAddress}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _addressId = value),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text(
                    apiErrorMessage(error),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            const SizedBox(height: 20),
            const StoreEyebrow('PAYMENT METHOD'),
            const SizedBox(height: 10),
            ...const [
              ('paystack', 'Paystack Checkout', 'Card and bank transfer'),
              ('flutterwave', 'Flutterwave', 'Cards and local payment methods'),
              ('bank_transfer', 'Bank Transfer', 'Direct bank transfer'),
            ].map(
              (option) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: StoreColors.line),
                ),
                title: Text(
                  option.$2,
                  style: const TextStyle(fontFamily: 'serif'),
                ),
                subtitle: Text(option.$3, style: const TextStyle(fontSize: 11)),
                leading: Icon(
                  _payment == option.$1
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: StoreColors.olive,
                ),
                onTap: () => setState(() => _payment = option.$1),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Orders remain pending until a payment provider is configured and confirms payment.',
                style: TextStyle(fontSize: 11, color: StoreColors.muted),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _placeOrder,
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('PLACE ORDER'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
