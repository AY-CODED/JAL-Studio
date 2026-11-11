import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
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
    padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: StoreColors.ink,
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C3027), StoreColors.ink],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: StoreColors.white.withValues(alpha: .12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: StoreColors.white.withValues(alpha: .2),
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: StoreColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName ?? 'Welcome to JAL Studio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: StoreColors.white,
                        fontFamily: 'serif',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email ?? 'SIGN IN TO YOUR ACCOUNT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        letterSpacing: 1,
                        fontSize: 10,
                        color: Color(0xFFC9C9C0),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userName == null
                          ? 'Your wardrobe, thoughtfully curated.'
                          : 'Your personal style, all in one place.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDDDDD6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              if (userName == null)
                IconButton(
                  tooltip: 'Sign in',
                  onPressed: onSignIn,
                  color: StoreColors.white,
                  icon: const Icon(Icons.arrow_forward_rounded),
                )
              else
                PopupMenuButton<String>(
                  tooltip: 'Account options',
                  iconColor: StoreColors.white,
                  onSelected: (value) {
                    if (value == 'edit') {
                      onOpen(const EditProfilePage());
                    } else {
                      onSignOut?.call();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit profile'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'signOut',
                      child: ListTile(
                        leading: Icon(Icons.logout_rounded),
                        title: Text('Sign out'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _StatsRow(signedIn: userName != null),
        const SizedBox(height: 24),
        _SectionHeading(
          title: 'My Measurements',
          action: 'View / Edit',
          onTap: () => onOpen(const BodyMeasurementsPage()),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _MeasurementSummary(signedIn: userName != null),
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeading(
          title: 'Recent Orders',
          action: 'View all',
          onTap: () => onOpen(const OrderHistoryPage()),
        ),
        const SizedBox(height: 8),
        if (userName != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Your real order history is available in View all.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Sign in to view your orders.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 12),
        const StoreEyebrow('YOUR ACCOUNT'),
        const SizedBox(height: 10),
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
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ProfileLink(
              title: item.$1,
              subtitle: item.$2,
              onTap: () => onOpen(item.$3),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StoreColors.oliveWash,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.workspace_premium_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Private Client Concierge\nNeed help? Our style experts are here for you.',
                  style: TextStyle(fontSize: 13, height: 1.5),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: StoreColors.white,
        border: Border.all(color: StoreColors.line),
        borderRadius: BorderRadius.circular(14),
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
    width: (MediaQuery.sizeOf(context).width - 52) / 3 < 180
        ? (MediaQuery.sizeOf(context).width - 52) / 3
        : 180,
    padding: const EdgeInsets.all(12),
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
        Text(value, style: Theme.of(context).textTheme.titleMedium),
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
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      TextButton(onPressed: onTap, child: Text(action)),
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
  Widget build(BuildContext context) {
    final icon = switch (title) {
      'Account Settings' => Icons.manage_accounts_outlined,
      'Notifications' => Icons.notifications_none_rounded,
      'Delivery Addresses' => Icons.location_on_outlined,
      'Messages' => Icons.chat_bubble_outline_rounded,
      'Help & Support' => Icons.support_agent_rounded,
      'Seller Studio' => Icons.storefront_outlined,
      'Admin Operations' => Icons.admin_panel_settings_outlined,
      _ => Icons.circle_outlined,
    };
    return Card(
      child: ListTile(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: StoreColors.oliveWash,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: StoreColors.ink),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: StoreColors.muted),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 21,
          color: StoreColors.muted,
        ),
        onTap: onTap,
      ),
    );
  }
}
