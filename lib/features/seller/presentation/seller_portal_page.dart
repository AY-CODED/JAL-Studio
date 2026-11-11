import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/store_components.dart';

class SellerPortalPage extends ConsumerStatefulWidget {
  const SellerPortalPage({super.key});

  @override
  ConsumerState<SellerPortalPage> createState() => _SellerPortalPageState();
}

class _SellerPortalPageState extends ConsumerState<SellerPortalPage> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  bool _sending = false;
  int _refresh = 0;

  @override
  void dispose() {
    _business.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _application() async {
    final response = await ref
        .read(apiClientProvider)
        .dio
        .get<Map<String, dynamic>>('/seller/applications/me');
    return response.data!['data'] as Map<String, dynamic>?;
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .post<void>(
            '/seller/applications',
            data: {
              'businessName': _business.text.trim(),
              'contactPhone': _phone.text.trim(),
              'description': _description.text.trim(),
            },
          );
      if (mounted) setState(() => _refresh++);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _addProduct() async {
    final product = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _NewProductDialog(),
    );
    if (product == null) return;
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .post<void>('/products/seller', data: product);
      if (mounted) setState(() => _refresh++);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _updateStock(String productId, int stock) async {
    final controller = TextEditingController(text: '$stock');
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Units available'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result < 0) return;
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .patch<void>('/products/seller/$productId', data: {'stock': result});
      if (mounted) setState(() => _refresh++);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _advanceOrder(String orderId, String status) async {
    final next = switch (status) {
      'paid' => 'processing',
      'processing' => 'shipped',
      'shipped' => 'delivered',
      _ => null,
    };
    if (next == null) return;
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .patch<void>(
            '/orders/seller/$orderId/status',
            data: {'status': next},
          );
      if (mounted) setState(() => _refresh++);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Seller Studio',
    child: FutureBuilder<Map<String, dynamic>?>(
      key: ValueKey(_refresh),
      future: _application(),
      builder: (context, applicationSnapshot) {
        if (applicationSnapshot.hasError) {
          return Center(
            child: Text(apiErrorMessage(applicationSnapshot.error!)),
          );
        }
        if (!applicationSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final application = applicationSnapshot.data;
        if (application?['status'] != 'approved') {
          if (application?['status'] == 'pending') {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Your seller application is awaiting review. We will update your account when it has been reviewed.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _applicationForm(application);
        }
        return _dashboard();
      },
    ),
  );

  Widget _applicationForm(
    Map<String, dynamic>? previous,
  ) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageIntro(
                icon: Icons.storefront_outlined,
                title: 'Sell with JAL Studio',
                subtitle: 'Apply to list and manage your atelier products.',
              ),
              if (previous?['status'] == 'rejected')
                const Text(
                  'Your previous application was not approved. Update your details to apply again.',
                  style: TextStyle(color: StoreColors.muted),
                ),
              TextFormField(
                controller: _business,
                decoration: const InputDecoration(labelText: 'Business name'),
                validator: (value) => (value?.trim().length ?? 0) < 2
                    ? 'Enter your business name'
                    : null,
              ),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Business phone'),
                validator: (value) => (value?.trim().length ?? 0) < 6
                    ? 'Enter a contact phone number'
                    : null,
              ),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Tell us about your atelier',
                ),
                validator: (value) => (value?.trim().length ?? 0) < 20
                    ? 'Please add at least 20 characters'
                    : null,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _sending ? null : _submitApplication,
                style: FilledButton.styleFrom(backgroundColor: StoreColors.ink),
                child: Text(_sending ? 'Submitting…' : 'Submit application'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _dashboard() => FutureBuilder(
    future: Future.wait([
      ref
          .read(apiClientProvider)
          .dio
          .get<Map<String, dynamic>>('/products/seller'),
      ref
          .read(apiClientProvider)
          .dio
          .get<Map<String, dynamic>>('/orders/seller'),
    ]),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text(apiErrorMessage(snapshot.error!)));
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final products = snapshot.data![0].data!['data'] as List<dynamic>;
      final orders = snapshot.data![1].data!['data'] as List<dynamic>;
      return ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const PageIntro(
            icon: Icons.storefront,
            title: 'Your atelier',
            subtitle: 'Manage listings, stock, and fulfilment.',
          ),
          FilledButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add product'),
          ),
          const SizedBox(height: 16),
          const Text('Products', style: TextStyle(fontSize: 20)),
          if (products.isEmpty) const Text('You have no product listings yet.'),
          ...products.map((raw) {
            final product = raw as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(product['name'] as String),
                subtitle: Text(
                  '${formatNaira(product['priceKobo'] as int)} · Stock ${product['stock']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.inventory_2_outlined),
                  tooltip: 'Update stock',
                  onPressed: () => _updateStock(
                    product['_id'] as String,
                    product['stock'] as int,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text('Orders', style: TextStyle(fontSize: 20)),
          if (orders.isEmpty) const Text('No customer orders yet.'),
          ...orders.map((raw) {
            final order = raw as Map<String, dynamic>;
            final status = order['status'] as String;
            return Card(
              child: ListTile(
                title: Text(order['orderNumber'] as String),
                subtitle: Text(
                  '${status.replaceAll('_', ' ')} · ${formatNaira(order['totalKobo'] as int)}',
                ),
                trailing: status == 'pending_payment'
                    ? const Text('Awaiting payment')
                    : status == 'delivered' || status == 'cancelled'
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        tooltip: 'Advance order status',
                        onPressed: () =>
                            _advanceOrder(order['_id'] as String, status),
                      ),
              ),
            );
          }),
        ],
      );
    },
  );
}

class _NewProductDialog extends StatefulWidget {
  const _NewProductDialog();

  @override
  State<_NewProductDialog> createState() => _NewProductDialogState();
}

class _NewProductDialogState extends State<_NewProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '1');
  final _image = TextEditingController();
  final _description = TextEditingController();
  String _category = 'menswear';

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _price.dispose();
    _stock.dispose();
    _image.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New product'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_name, 'Product name'),
            _field(_brand, 'Brand / atelier'),
            _field(_price, 'Price in naira', keyboard: TextInputType.number),
            _field(_stock, 'Available stock', keyboard: TextInputType.number),
            _field(_image, 'Image URL or /media path'),
            _field(_description, 'Description', required: false),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'menswear', child: Text('Menswear')),
                DropdownMenuItem(
                  value: 'womenswear',
                  child: Text('Womenswear'),
                ),
                DropdownMenuItem(
                  value: 'accessories',
                  child: Text('Accessories'),
                ),
                DropdownMenuItem(
                  value: 'activewear',
                  child: Text('Activewear'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _category = value ?? 'menswear'),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          final priceKobo = (double.parse(_price.text) * 100).round();
          final slug = _name.text
              .trim()
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
              .replaceAll(RegExp(r'^-|-$'), '');
          Navigator.pop(context, {
            'slug': slug,
            'name': _name.text.trim(),
            'brand': _brand.text.trim(),
            'priceKobo': priceKobo,
            'stock': int.parse(_stock.text),
            'imageUrl': _image.text.trim(),
            'description': _description.text.trim(),
            'category': _category,
            'sizes': <String>[],
            'colors': <String>[],
            'styles': <String>[],
          });
        },
        child: const Text('Create listing'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    bool required = true,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    decoration: InputDecoration(labelText: label),
    validator: (value) {
      if (!required && (value?.isEmpty ?? true)) return null;
      if (value == null || value.trim().isEmpty) return 'Required';
      if (label == 'Price in naira' &&
          (double.tryParse(value) == null || double.parse(value) <= 0)) {
        return 'Enter a valid price';
      }
      if (label == 'Available stock' &&
          (int.tryParse(value) == null || int.parse(value) < 0)) {
        return 'Enter a valid stock amount';
      }
      return null;
    },
  );
}
