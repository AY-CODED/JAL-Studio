import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/store_components.dart';
import '../../account/data/account_repository.dart';
import '../../account/presentation/account_pages.dart';
import '../../catalog/presentation/catalog_widgets.dart';
import '../data/cart_repository.dart';
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
  String? _addressId;
  bool _isSubmitting = false;
  String? _activeOrderId;
  String? _activeOrderNumber;
  late final String _checkoutKey;

  @override
  void initState() {
    super.initState();
    _checkoutKey = OrderRepository(ref.read(apiClientProvider))
        .newIdempotencyKey();
  }

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
      final enabled = await ref.read(paystackEnabledProvider.future);
      if (!enabled) {
        throw StateError(
          'Online payment is not configured. Add your Paystack test secret to the backend .env file.',
        );
      }
      final order = await ref
          .read(orderRepositoryProvider)
          .createOrder(addressId: addressId, idempotencyKey: _checkoutKey);
      if (!mounted) return;
      setState(() {
        _activeOrderId = order.id;
        _activeOrderNumber = order.orderNumber;
      });
      await _openPayment();
    } catch (error) {
      if (mounted) {
        final message = error is StateError
            ? error.message.toString()
            : apiErrorMessage(error);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _openPayment() async {
    final orderId = _activeOrderId;
    if (orderId == null) return;
    final redirect = await ref
        .read(orderRepositoryProvider)
        .startPaystack(orderId);
    final opened = await launchUrl(
      redirect.authorizationUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) throw StateError('Could not open the Paystack payment page.');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pay securely with Paystack. Return here after checkout to confirm your payment.',
          ),
        ),
      );
    }
  }

  Future<void> _verifyPayment() async {
    final orderId = _activeOrderId;
    if (orderId == null) return;
    setState(() => _isSubmitting = true);
    try {
      final status = await ref
          .read(orderRepositoryProvider)
          .verifyPayment(orderId);
      ref.invalidate(ordersProvider);
      ref.invalidate(cartProvider);
      if (!mounted) return;
      if (status == 'paid' ||
          status == 'processing' ||
          status == 'shipped' ||
          status == 'delivered') {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Payment confirmed'),
            content: Text('Order $_activeOrderNumber has been paid securely.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
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
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: StoreColors.line),
              ),
              title: const Text(
                'Paystack secure checkout',
                style: TextStyle(fontFamily: 'serif'),
              ),
              subtitle: const Text(
                'Cards and supported local payment methods',
                style: TextStyle(fontSize: 11),
              ),
              leading: const Icon(Icons.lock_outline, color: StoreColors.olive),
            ),
            ref
                .watch(paystackEnabledProvider)
                .when(
                  data: (enabled) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      enabled
                          ? 'You will be redirected to Paystack. Your order is confirmed only after the backend verifies payment.'
                          : 'Paystack is not configured. Add PAYSTACK_SECRET_KEY to the backend .env file to enable test checkout.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: StoreColors.muted,
                      ),
                    ),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (error, _) => Text(
                    apiErrorMessage(error),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            if (_activeOrderId != null) ...[
              const SizedBox(height: 8),
              Text('Order $_activeOrderNumber is awaiting payment.'),
              OutlinedButton(
                onPressed: _isSubmitting ? null : _openPayment,
                child: const Text('Open Paystack checkout'),
              ),
              TextButton(
                onPressed: _isSubmitting ? null : _verifyPayment,
                child: const Text('I have paid - verify payment'),
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    _isSubmitting ||
                        ref.watch(paystackEnabledProvider).asData?.value != true
                    ? null
                    : _placeOrder,
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
