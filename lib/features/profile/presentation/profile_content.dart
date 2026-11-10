import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/store_colors.dart';
import '../../account/data/account_repository.dart';
import '../../account/presentation/account_pages.dart';
import '../../cart_checkout/data/order_repository.dart';
import '../../messaging/presentation/messages_page.dart';
import '../../seller/presentation/seller_portal_page.dart';
import '../../support/presentation/support_page.dart';
import '../../admin/presentation/admin_operations_page.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.onOpen,
    this.userName,
    this.email,
    this.onSignIn,
    this.onSignOut,
    this.isAdmin = false,
  });

  final ValueChanged<Widget> onOpen;
  final String? userName;
  final String? email;
  final VoidCallback? onSignIn;
  final VoidCallback? onSignOut;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: StoreColors.sand,
              child: Icon(Icons.person, color: StoreColors.ink, size: 34),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName ?? 'Welcome to EKŌ',
                    style: const TextStyle(fontFamily: 'serif', fontSize: 18),
                  ),
                  Text(
                    email ?? 'SIGN IN TO YOUR ACCOUNT',
                    style: const TextStyle(
                      letterSpacing: 1.2,
                      fontSize: 9,
                      color: StoreColors.muted,
                    ),
                  ),
                  Text(
                    userName == null
                        ? 'Sign in to manage your orders and wardrobe.'
                        : 'Style is a language. I speak it well.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: StoreColors.muted,
                    ),
                  ),
                  const Text(
                    '⌖ Lagos, Nigeria',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (userName == null)
              TextButton(onPressed: onSignIn, child: const Text('Sign in'))
            else
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onOpen(const EditProfilePage());
                  } else {
                    onSignOut?.call();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit profile')),
                  PopupMenuItem(value: 'signOut', child: Text('Sign out')),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Account'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _StatsRow(signedIn: userName != null),
        const SizedBox(height: 18),
        _SectionHeading(
          title: 'My Measurements',
          action: 'View / Edit',
          onTap: () => onOpen(const BodyMeasurementsPage()),
        ),
        const SizedBox(height: 10),
        _MeasurementSummary(signedIn: userName != null),
        const SizedBox(height: 22),
        _SectionHeading(
          title: 'Recent Orders',
          action: 'View all',
          onTap: () => onOpen(const OrderHistoryPage()),
        ),
        const SizedBox(height: 8),
        if (userName != null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Your real order history is available in View all.',
              style: TextStyle(fontSize: 12, color: StoreColors.muted),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Sign in to view your orders.',
              style: TextStyle(fontSize: 12, color: StoreColors.muted),
            ),
          ),
        const SizedBox(height: 14),
        ...[
          (
            'Account Settings',
            'Personal info, email, password',
            const AccountSettingsPage(),
          ),
          (
            'Notifications',
            'Your notification preferences',
            const NotificationsPage(),
          ),
          (
            'Delivery Addresses',
            'Manage your saved addresses',
            const DeliveryAddressesPage(),
          ),
          (
            'Messages',
            'Chat with your stylist and ateliers',
            const MessagesPage(),
          ),
          (
            'Help & Support',
            'Send and follow support requests',
            const SupportPage(),
          ),
          if (userName != null)
            (
              'Seller Studio',
              'Apply to sell and manage your atelier',
              const SellerPortalPage(),
            ),
          if (isAdmin)
            (
              'Admin Operations',
              'Review the marketplace and customer requests',
              const AdminOperationsPage(),
            ),
        ].map(
          (item) => _ProfileLink(
            title: item.$1,
            subtitle: item.$2,
            onTap: () => onOpen(item.$3),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StoreColors.sand,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.workspace_premium_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Private Client Concierge\nNeed help? Our style experts are here for you.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderCount = signedIn
        ? ref.watch(ordersProvider).asData?.value.length
        : null;
    final wishlistCount = signedIn
        ? ref.watch(wishlistProvider).asData?.value.length
        : null;
    final measurements = signedIn
        ? ref.watch(accountProfileProvider).asData?.value['measurements']
              as Map<String, dynamic>?
        : null;
    final measurementCount =
        measurements?.values
            .where((value) => value is num && value > 0)
            .length ??
        0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: StoreColors.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(value: orderCount?.toString() ?? '—', label: 'Orders'),
          _Stat(value: '$measurementCount', label: 'Measurements'),
          _Stat(value: wishlistCount?.toString() ?? '—', label: 'Saved looks'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 18, fontFamily: 'serif')),
      Text(
        label,
        style: const TextStyle(fontSize: 9, color: StoreColors.muted),
      ),
    ],
  );
}

class _MeasurementSummary extends ConsumerWidget {
  const _MeasurementSummary({required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = signedIn
        ? ref.watch(accountProfileProvider).asData?.value['measurements']
              as Map<String, dynamic>?
        : null;
    const labels = {
      'chestCm': 'Chest',
      'waistCm': 'Waist',
      'seatCm': 'Seat',
      'shoulderCm': 'Shoulder',
      'sleeveCm': 'Sleeve',
      'insideLegCm': 'Inside leg',
    };
    final cells = labels.entries
        .where((entry) => measurements?[entry.key] != null)
        .map(
          (entry) => _MeasurementTile(
            label: entry.value,
            value: '${measurements![entry.key]} cm',
          ),
        )
        .toList();
    if (cells.isEmpty) {
      return const Text(
        'Add measurements to save your preferred fit.',
        style: TextStyle(color: StoreColors.muted, fontSize: 12),
      );
    }
    return Wrap(spacing: 8, runSpacing: 8, children: cells);
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    width: (MediaQuery.sizeOf(context).width - 52) / 3,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: StoreColors.line),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: StoreColors.muted),
        ),
        Text(value, style: const TextStyle(fontSize: 15, fontFamily: 'serif')),
      ],
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 18, fontFamily: 'serif')),
      TextButton(
        onPressed: onTap,
        child: Text(
          action,
          style: const TextStyle(color: StoreColors.muted, fontSize: 11),
        ),
      ),
    ],
  );
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.circle_outlined, size: 20),
    title: Text(title, style: const TextStyle(fontSize: 13)),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 10, color: StoreColors.muted),
    ),
    trailing: const Icon(Icons.chevron_right, size: 19),
    onTap: onTap,
  );
}
