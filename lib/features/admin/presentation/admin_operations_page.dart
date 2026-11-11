import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/store_components.dart';

class AdminOperationsPage extends ConsumerStatefulWidget {
  const AdminOperationsPage({super.key});

  @override
  ConsumerState<AdminOperationsPage> createState() =>
      _AdminOperationsPageState();
}

class _AdminOperationsPageState extends ConsumerState<AdminOperationsPage> {
  int _revision = 0;
  bool _busy = false;

  Future<List<dynamic>> _load() => Future.wait([
    ref
        .read(apiClientProvider)
        .dio
        .get<Map<String, dynamic>>('/seller/admin/applications'),
    ref
        .read(apiClientProvider)
        .dio
        .get<Map<String, dynamic>>('/support/admin/tickets'),
    ref.read(apiClientProvider).dio.get<Map<String, dynamic>>('/orders/seller'),
    ref
        .read(apiClientProvider)
        .dio
        .get<Map<String, dynamic>>('/products/admin'),
  ]);

  Future<void> _update(String path, Map<String, Object?> body) async {
    setState(() => _busy = true);
    try {
      await ref.read(apiClientProvider).dio.patch<void>(path, data: body);
      if (mounted) setState(() => _revision++);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reviewTicket(Map<String, dynamic> ticket) async {
    final noteController = TextEditingController(
      text: ticket['staffNote'] as String? ?? '',
    );
    var status = ticket['status'] as String;
    final result = await showDialog<({String status, String note})>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Review support request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['message'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In progress'),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => status = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reply / staff note',
                    hintText: 'This note will be visible to the customer.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, (
                status: status,
                note: noteController.text.trim(),
              )),
              child: const Text('Save update'),
            ),
          ],
        ),
      ),
    );
    noteController.dispose();
    if (result == null) return;
    await _update('/support/admin/tickets/${ticket['_id']}', {
      'status': result.status,
      if (result.note.isNotEmpty) 'staffNote': result.note,
    });
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Admin Operations',
    actions: [
      IconButton(
        tooltip: 'Refresh admin data',
        onPressed: _busy ? null : () => setState(() => _revision++),
        icon: const Icon(Icons.refresh_rounded),
      ),
    ],
    child: FutureBuilder<List<dynamic>>(
      key: ValueKey(_revision),
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 42,
                    color: StoreColors.olive,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Could not load admin workspace',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    apiErrorMessage(snapshot.error!),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => setState(() => _revision++),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final applications = snapshot.data![0].data!['data'] as List<dynamic>;
        final tickets = snapshot.data![1].data!['data'] as List<dynamic>;
        final orders = snapshot.data![2].data!['data'] as List<dynamic>;
        final products = snapshot.data![3].data!['data'] as List<dynamic>;
        final returns = orders.where((raw) {
          final order = raw as Map<String, dynamic>;
          final request = order['returnRequest'] as Map<String, dynamic>?;
          return request?['status'] == 'requested';
        }).length;

        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StoreEyebrow('JAL STUDIO · CONTROL CENTRE'),
                    const SizedBox(height: 6),
                    Text(
                      'Marketplace overview',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Seller reviews',
                            value: '${applications.length}',
                            icon: Icons.storefront_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricCard(
                            label: 'Products',
                            value: '${products.length}',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricCard(
                            label: 'Returns',
                            value: '$returns',
                            icon: Icons.assignment_return_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricCard(
                            label: 'Support',
                            value:
                                '${tickets.where((raw) => (raw as Map<String, dynamic>)['status'] != 'resolved').length}',
                            icon: Icons.support_agent_outlined,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Material(
                color: StoreColors.paper,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: StoreColors.ink,
                  unselectedLabelColor: StoreColors.muted,
                  indicatorColor: StoreColors.olive,
                  tabs: [
                    Tab(text: 'Sellers (${applications.length})'),
                    Tab(text: 'Products (${products.length})'),
                    Tab(text: 'Orders (${orders.length})'),
                    Tab(text: 'Support (${tickets.length})'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _sellerApplications(applications),
                    _productListings(products),
                    _orders(orders),
                    _tickets(tickets),
                  ],
                ),
              ),
              if (_busy) const LinearProgressIndicator(),
            ],
          ),
        );
      },
    ),
  );

  Widget _sellerApplications(List<dynamic> applications) => _AdminList(
    title: 'Seller applications',
    subtitle: 'Verify each atelier before granting marketplace access.',
    emptyMessage: 'No seller applications need review.',
    items: applications,
    itemBuilder: (raw) {
      final application = raw as Map<String, dynamic>;
      final details =
          application['sellerApplication'] as Map<String, dynamic>? ?? {};
      final userId = application['_id'] as String;
      return _AdminCard(
        icon: Icons.storefront_outlined,
        title: details['businessName'] as String? ?? 'Seller application',
        eyebrow: '${application['fullName']} · ${application['email']}',
        description:
            details['description'] as String? ??
            'No business description provided.',
        footer:
            'Contact: ${details['contactPhone'] ?? application['phone'] ?? 'Not provided'}',
        actions: [
          OutlinedButton(
            onPressed: _busy
                ? null
                : () => _update('/seller/admin/applications/$userId', {
                    'status': 'rejected',
                  }),
            child: const Text('Decline'),
          ),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _update('/seller/admin/applications/$userId', {
                    'status': 'approved',
                  }),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Approve seller'),
          ),
        ],
      );
    },
  );

  Widget _productListings(List<dynamic> products) => _AdminList(
    title: 'Product catalogue',
    subtitle: 'Review marketplace listings and control their visibility.',
    emptyMessage: 'No marketplace products yet.',
    items: products,
    itemBuilder: (raw) {
      final product = raw as Map<String, dynamic>;
      final seller = product['seller'] as Map<String, dynamic>?;
      final isActive = product['isActive'] as bool? ?? false;
      final productId = product['_id'] as String;
      return _AdminCard(
        icon: Icons.inventory_2_outlined,
        title: product['name'] as String? ?? 'Untitled product',
        eyebrow:
            '${product['brand'] ?? 'Independent atelier'} · ${formatNaira(product['priceKobo'] as int? ?? 0)}',
        description:
            '${product['category'] ?? 'Uncategorised'} · Stock ${product['stock'] ?? 0}',
        footer:
            'Seller: ${seller?['fullName'] ?? 'JAL Studio'}${seller?['email'] == null ? '' : ' · ${seller!['email']}'}',
        status: isActive ? 'Visible in shop' : 'Hidden from shop',
        actions: [
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _update('/products/admin/$productId/status', {
                    'isActive': !isActive,
                  }),
            icon: Icon(
              isActive
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            label: Text(isActive ? 'Hide listing' : 'Publish listing'),
          ),
        ],
      );
    },
  );

  Widget _orders(List<dynamic> orders) => _AdminList(
    title: 'Orders & returns',
    subtitle: 'Advance paid orders through fulfilment and review return requests. Do not mark an order paid manually.',
    emptyMessage: 'No marketplace orders yet.',
    items: orders,
    itemBuilder: (raw) {
      final order = raw as Map<String, dynamic>;
      final orderId = order['_id'] as String;
      final status = order['status'] as String? ?? 'unknown';
      final returnRequest = order['returnRequest'] as Map<String, dynamic>?;
      final returnStatus = returnRequest?['status'] as String?;
      final nextStatus = switch (status) {
        'paid' => 'processing',
        'processing' => 'shipped',
        'shipped' => 'delivered',
        _ => null,
      };
      final user = order['user'] as Map<String, dynamic>?;
      final items = order['items'] as List<dynamic>? ?? const [];
      return _AdminCard(
        icon: Icons.receipt_long_outlined,
        title: order['orderNumber'] as String? ?? 'Order',
        eyebrow:
            '${user?['fullName'] ?? 'Customer'}${user?['email'] == null ? '' : ' · ${user!['email']}'}',
        description: items
            .map((item) {
              final product = item as Map<String, dynamic>;
              return '${product['name']} × ${product['quantity']}';
            })
            .join('  ·  '),
        footer:
            '${formatNaira(order['totalKobo'] as int? ?? 0)} · ${status.replaceAll('_', ' ')}',
        status: returnStatus == 'requested'
            ? 'Return requested: ${returnRequest?['reason'] ?? 'No reason provided'}'
            : null,
        actions: [
          if (returnStatus == 'requested') ...[
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _update('/orders/$orderId/admin-status', {
                      'returnStatus': 'rejected',
                    }),
              child: const Text('Decline return'),
            ),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _update('/orders/$orderId/admin-status', {
                      'returnStatus': 'approved',
                    }),
              child: const Text('Approve return request'),
            ),
          ] else if (nextStatus != null)
            FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () => _update('/orders/$orderId/admin-status', {
                      'status': nextStatus,
                    }),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text('Mark $nextStatus'),
            )
          else if (status == 'pending_payment')
            const Text(
              'Awaiting verified payment',
              style: TextStyle(color: StoreColors.muted, fontSize: 12),
            ),
        ],
      );
    },
  );

  Widget _tickets(List<dynamic> tickets) => _AdminList(
    title: 'Customer support',
    subtitle: 'Update request status and send a note visible to the customer.',
    emptyMessage: 'No support requests have been submitted.',
    items: tickets,
    itemBuilder: (raw) {
      final ticket = raw as Map<String, dynamic>;
      final user = ticket['user'] as Map<String, dynamic>?;
      final status = ticket['status'] as String? ?? 'open';
      return _AdminCard(
        icon: Icons.support_agent_outlined,
        title: ticket['subject'] as String? ?? 'Support request',
        eyebrow: '${user?['fullName'] ?? 'Customer'} · ${user?['email'] ?? ''}',
        description: ticket['message'] as String? ?? '',
        footer: 'Submitted ${_formatDate(ticket['createdAt'] as String?)}',
        status: (ticket['staffNote'] as String?)?.isNotEmpty == true
            ? 'Last note: ${ticket['staffNote']}'
            : null,
        actions: [
          OutlinedButton.icon(
            onPressed: _busy ? null : () => _reviewTicket(ticket),
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(
              status == 'resolved' ? 'Update reply' : 'Review & reply',
            ),
          ),
        ],
      );
    },
  );

  String _formatDate(String? value) {
    if (value == null) return 'date unavailable';
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return 'date unavailable';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _AdminList extends StatelessWidget {
  const _AdminList({
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.items,
    required this.itemBuilder,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<dynamic> items;
  final Widget Function(dynamic item) itemBuilder;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
      ),
      const SizedBox(height: 16),
      if (items.isEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        )
      else
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: itemBuilder(item),
          ),
        ),
    ],
  );
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.footer,
    required this.actions,
    this.status,
  });

  final IconData icon;
  final String title;
  final String eyebrow;
  final String description;
  final String footer;
  final String? status;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: StoreColors.oliveWash,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: StoreColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: StoreColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 8),
          Text(footer, style: Theme.of(context).textTheme.bodySmall),
          if (status != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: StoreColors.oliveWash,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                status!,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
        ],
      ),
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    decoration: BoxDecoration(
      color: StoreColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: StoreColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: StoreColors.olive),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9, color: StoreColors.muted),
        ),
      ],
    ),
  );
}
