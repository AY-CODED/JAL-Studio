import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../../account/presentation/account_pages.dart';
import '../../catalog/presentation/catalog_widgets.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Messages',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StoreEyebrow('ATELIER & CONCIERGE'),
            const Text(
              'Messages',
              style: TextStyle(fontSize: 32, fontFamily: 'serif'),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search conversations, orders, sellers...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const CategoryChips(
              categories: ['All', 'Ateliers', 'Concierge', 'Orders'],
            ),
            const SizedBox(height: 12),
            ...[
              ('EKŌ Private Styling', 'Upgrade to Premium · 1 hour ago'),
              ('Atelier Synergy', 'Eli: I’ve prepared some fits. Here’s…'),
              ('EKŌ Client Refills', 'Your wardrobe is 70% Luxe & 30% You.'),
              ('BRIKK Studio', 'Eli: New arrivals just landed.'),
              ('Kensington Atelier', 'Your appointment is confirmed.'),
            ].map(
              (message) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: StoreColors.sand,
                  child: Icon(
                    Icons.storefront_outlined,
                    color: StoreColors.ink,
                  ),
                ),
                title: Text(
                  message.$1,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  message.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SimpleInfoPage(title: message.$1, message: message.$2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
