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

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Admin Operations',
    child: FutureBuilder(
      key: ValueKey(_revision),
      future: _load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(apiErrorMessage(snapshot.error!)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final applications = snapshot.data![0].data!['data'] as List<dynamic>;
        final tickets = snapshot.data![1].data!['data'] as List<dynamic>;
        final orders = snapshot.data![2].data!['data'] as List<dynamic>;
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const PageIntro(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Marketplace operations',
              subtitle: 'Review sellers, support requests, and fulfilment.',
            ),
            const Text('Seller applications', style: TextStyle(fontSize: 20)),
            if (applications.isEmpty)
              const Text('No seller applications need review.'),
            ...applications.map((raw) {
              final application = raw as Map<String, dynamic>;
              final details =
                  application['sellerApplication'] as Map<String, dynamic>;
              final userId = application['_id'] as String;
              return Card(
                child: ListTile(
                  title: Text(details['businessName'] as String),
                  subtitle: Text(
                    '${application['fullName']} · ${application['email']}\n${details['description']}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    enabled: !_busy,
                    onSelected: (status) => _update(
                      '/seller/admin/applications/$userId',
                      {'status': status},
                    ),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'approved', child: Text('Approve')),
                      PopupMenuItem(value: 'rejected', child: Text('Reject')),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text('Customer support', style: TextStyle(fontSize: 20)),
            if (tickets.isEmpty) const Text('No support requests.'),
            ...tickets.map((raw) {
              final ticket = raw as Map<String, dynamic>;
              final user = ticket['user'] as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(ticket['subject'] as String),
                  subtitle: Text(
                    '${user['fullName']} · ${ticket['message']}\nStatus: ${ticket['status']}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    enabled: !_busy,
                    onSelected: (status) => _update(
                      '/support/admin/tickets/${ticket['_id']}',
                      {'status': status},
                    ),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'in_progress',
                        child: Text('In progress'),
                      ),
                      PopupMenuItem(value: 'resolved', child: Text('Resolve')),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text('Seller orders', style: TextStyle(fontSize: 20)),
            if (orders.isEmpty) const Text('No seller orders.'),
            ...orders.map((raw) {
              final order = raw as Map<String, dynamic>;
              final status = order['status'] as String;
              return Card(
                child: ListTile(
                  title: Text(order['orderNumber'] as String),
                  subtitle: Text(
                    '$status · ${formatNaira(order['totalKobo'] as int)}',
                  ),
                  trailing: PopupMenuButton<String>(
                    enabled: !_busy && status != 'pending_payment',
                    onSelected: (nextStatus) => _update(
                      '/orders/${order['_id']}/admin-status',
                      {'status': nextStatus},
                    ),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'processing',
                        child: Text('Processing'),
                      ),
                      PopupMenuItem(value: 'shipped', child: Text('Shipped')),
                      PopupMenuItem(
                        value: 'delivered',
                        child: Text('Delivered'),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Do not mark an order paid manually. Refunds and payment disputes must be verified with Paystack and handled through its dashboard until refund APIs are enabled.',
                style: TextStyle(color: StoreColors.muted, fontSize: 12),
              ),
            ),
          ],
        );
      },
    ),
  );
}
