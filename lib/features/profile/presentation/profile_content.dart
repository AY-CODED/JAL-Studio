import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../../account/presentation/account_pages.dart';
import '../../messaging/presentation/messages_page.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.onOpen,
    this.userName,
    this.email,
    this.onSignIn,
    this.onSignOut,
  });

  final ValueChanged<Widget> onOpen;
  final String? userName;
  final String? email;
  final VoidCallback? onSignIn;
  final VoidCallback? onSignOut;

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
        const _StatsRow(),
        const SizedBox(height: 18),
        _SectionHeading(
          title: 'My Measurements',
          action: 'View / Edit',
          onTap: () => onOpen(const BodyMeasurementsPage()),
        ),
        const SizedBox(height: 10),
        const _MeasurementSummary(),
        const SizedBox(height: 22),
        _SectionHeading(
          title: 'Recent Orders',
          action: 'View all',
          onTap: () => onOpen(const OrderHistoryPage()),
        ),
        const SizedBox(height: 8),
        ...[
          'Custom Suit Set',
          'Linen Blend Outfit',
          'Classic Overcoat',
        ].map((name) => _OrderPreview(name: name)),
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
          ('Help & Support', 'FAQs and contact us', const HelpSupportPage()),
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

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      border: Border.all(color: StoreColors.line),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Stat(value: '12', label: 'Orders'),
        _Stat(value: '3', label: 'Measurements'),
        _Stat(value: '2', label: 'Saved looks'),
        _Stat(value: '1 year+', label: 'Member since'),
      ],
    ),
  );
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

class _MeasurementSummary extends StatelessWidget {
  const _MeasurementSummary();
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: const [
      _MeasurementTile(label: 'Chest', value: '40 in'),
      _MeasurementTile(label: 'Waist', value: '32 in'),
      _MeasurementTile(label: 'Hips', value: '38 in'),
      _MeasurementTile(label: 'Height', value: '6\'0"'),
      _MeasurementTile(label: 'Weight', value: '75 kg'),
      _MeasurementTile(label: 'Shoe size', value: '10 (US)'),
    ],
  );
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

class _OrderPreview extends StatelessWidget {
  const _OrderPreview({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/banner2.jpg',
        width: 42,
        height: 46,
        fit: BoxFit.cover,
      ),
    ),
    title: Text(name, style: const TextStyle(fontSize: 12)),
    subtitle: const Text('Delivered', style: TextStyle(fontSize: 10)),
    trailing: const Icon(Icons.chevron_right, size: 18),
    dense: true,
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
