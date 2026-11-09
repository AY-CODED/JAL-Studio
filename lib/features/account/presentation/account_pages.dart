import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../data/account_repository.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Account Settings',
    child: SingleChildScrollView(
      child: Column(
        children: [
          const PageIntro(
            icon: Icons.lock_outline,
            title: 'Account Settings',
            subtitle: 'Privacy, security and preferences',
          ),
          ...[
            (
              'Personal information',
              'Edit your name and contact details',
              const EditProfilePage(),
            ),
            (
              'Password & security',
              'Face ID is enabled',
              const SimpleInfoPage(
                title: 'Password & security',
                message: 'Manage your password and sign-in security.',
              ),
            ),
            (
              'Communication preferences',
              'Email and SMS',
              const NotificationsPage(),
            ),
            (
              'Privacy controls',
              'Data and personalisation',
              const SimpleInfoPage(
                title: 'Privacy controls',
                message: 'Choose how your personal data is used.',
              ),
            ),
            (
              'Delete account',
              'Permanently remove your account',
              const SimpleInfoPage(
                title: 'Delete account',
                message: 'Contact support to request account deletion.',
              ),
            ),
          ].map(
            (item) => _SettingsRow(
              title: item.$1,
              subtitle: item.$2,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => item.$3),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Edit Profile',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const PageIntro(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Your member information',
            ),
            const CircleAvatar(
              radius: 42,
              backgroundColor: StoreColors.ink,
              child: Text(
                'OO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'serif',
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _ProfileTextField(
              label: 'FULL NAME',
              initial: 'Obinna Okeke',
            ),
            const _ProfileTextField(
              label: 'EMAIL ADDRESS',
              initial: 'obinna.okeke@email.com',
            ),
            const _ProfileTextField(
              label: 'PHONE NUMBER',
              initial: '+234 803 452 1970',
            ),
            const _ProfileTextField(
              label: 'DATE OF BIRTH',
              initial: '18 September 1990',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile changes saved')),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({required this.label, required this.initial});
  final String label;
  final String initial;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 9,
          letterSpacing: 1.2,
          color: StoreColors.muted,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: StoreColors.line),
        ),
      ),
    ),
  );
}

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _current = true;
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Order History',
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _current = true),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      color: _current ? StoreColors.ink : StoreColors.muted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _current = false),
                  child: Text(
                    'Past orders',
                    style: TextStyle(
                      color: !_current ? StoreColors.ink : StoreColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          if (_current)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: StoreColors.line),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER #EKO-260508',
                      style: TextStyle(fontSize: 9, color: StoreColors.muted),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preparing your order',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/banner2.jpg',
                          width: 62,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/banner3.jpg',
                          width: 62,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        const Text('2 pieces', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    const Divider(height: 24),
                    const PriceLine(
                      title: 'Estimated delivery',
                      amount: '₦468,500',
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const SimpleInfoPage(
                              title: 'Track order',
                              message: 'Your order is being prepared by the atelier.',
                            ),
                          ),
                        ),
                        child: const Text('Track order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_current)
            const ListTile(
              title: Text('12 FEB 2026 · #EKO-260212'),
              subtitle: Text('Delivered'),
              trailing: Text('₦280,000'),
            ),
        ],
      ),
    ),
  );
}

class BodyMeasurementsPage extends StatelessWidget {
  const BodyMeasurementsPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Body Measurements',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 190,
              color: StoreColors.sand,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.accessibility_new,
                    size: 110,
                    color: Color(0xFF9A9A90),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROFILE',
                        style: TextStyle(fontSize: 9, color: StoreColors.muted),
                      ),
                      Text(
                        'Regular fit',
                        style: TextStyle(fontSize: 23, fontFamily: 'serif'),
                      ),
                      Text(
                        'Last updated 14 March 2026',
                        style: TextStyle(fontSize: 9, color: StoreColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 0,
              runSpacing: 0,
              children: [
                _MeasureCell(label: 'Chest', value: '102 cm'),
                _MeasureCell(label: 'Waist', value: '86 cm'),
                _MeasureCell(label: 'Seat', value: '100 cm'),
                _MeasureCell(label: 'Shoulder', value: '47 cm'),
                _MeasureCell(label: 'Sleeve', value: '64 cm'),
                _MeasureCell(label: 'Inside leg', value: '81 cm'),
              ],
            ),
            const SizedBox(height: 18),
            const ListTile(
              tileColor: Color(0xFFE9ECE5),
              leading: Icon(Icons.straighten),
              title: Text(
                'Your fit, remembered',
                style: TextStyle(fontSize: 12),
              ),
              subtitle: Text(
                'We use these measurements to recommend your best size.',
                style: TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitting appointment request started'),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('Book a fitting appointment'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MeasureCell extends StatelessWidget {
  const _MeasureCell({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    width: (MediaQuery.sizeOf(context).width - 38) / 2,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: StoreColors.line)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: StoreColors.muted),
        ),
        Text(value, style: const TextStyle(fontFamily: 'serif', fontSize: 17)),
      ],
    ),
  );
}

class DeliveryAddressesPage extends ConsumerWidget {
  const DeliveryAddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    return StorePageScaffold(
      title: 'Delivery Addresses',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageIntro(
              icon: Icons.location_on_outlined,
              title: 'Your addresses',
              subtitle: 'Manage where your orders arrive.',
            ),
            addresses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                children: [
                  Text(apiErrorMessage(error)),
                  TextButton(
                    onPressed: () => ref.invalidate(addressesProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
              data: (items) => items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No saved delivery addresses yet.'),
                    )
                  : Column(
                      children: items
                          .map(
                            (address) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${address.label} · ${address.fullName}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (address.isDefault)
                                          const Chip(label: Text('DEFAULT')),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${address.street}\n${address.city}, ${address.state}'
                                      '${address.postalCode == null ? '' : ' ${address.postalCode}'}\n'
                                      '${address.phone}',
                                    ),
                                    Wrap(
                                      children: [
                                        if (!address.isDefault)
                                          TextButton(
                                            onPressed: () => _updateAddress(
                                              context,
                                              ref,
                                              () => ref
                                                  .read(
                                                    accountRepositoryProvider,
                                                  )
                                                  .setDefaultAddress(
                                                    address.id,
                                                  ),
                                            ),
                                            child: const Text('Make default'),
                                          ),
                                        TextButton(
                                          onPressed: () => _updateAddress(
                                            context,
                                            ref,
                                            () => ref
                                                .read(accountRepositoryProvider)
                                                .removeAddress(address.id),
                                          ),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const AddAddressPage()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add a new address'),
              style: OutlinedButton.styleFrom(
                foregroundColor: StoreColors.ink,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAddress(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() update,
  ) async {
    try {
      await update();
      ref.invalidate(addressesProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }
}

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({super.key});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _label = TextEditingController(text: 'Home');
  final _name = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _phone = TextEditingController();
  final _postalCode = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _name.dispose();
    _street.dispose();
    _city.dispose();
    _state.dispose();
    _phone.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(accountRepositoryProvider).addAddress({
        'label': _label.text.trim(),
        'fullName': _name.text.trim(),
        'street': _street.text.trim(),
        'city': _city.text.trim(),
        'state': _state.text.trim(),
        'phone': _phone.text.trim(),
        if (_postalCode.text.trim().isNotEmpty)
          'postalCode': _postalCode.text.trim(),
      });
      ref.invalidate(addressesProvider);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'New address',
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _addressField(_label, 'ADDRESS LABEL'),
            _addressField(_name, 'FULL NAME'),
            _addressField(_street, 'STREET ADDRESS'),
            _addressField(_city, 'CITY'),
            _addressField(_state, 'STATE'),
            _addressField(
              _phone,
              'PHONE NUMBER',
              keyboardType: TextInputType.phone,
            ),
            _addressField(_postalCode, 'POSTAL CODE', required: false),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(_saving ? 'Saving…' : 'Save address'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _addressField(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboardType,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) => required && (value?.trim().isEmpty ?? true)
          ? 'Enter ${label.toLowerCase()}'
          : null,
    ),
  );
}

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final List<String> _titles = [
    'Order updates',
    'Private styling',
    'New collections',
    'Offers & events',
  ];
  final List<String> _subtitles = [
    'Delivery and payment notifications',
    'Messages from your concierge',
    'Editorial launches and early access',
    'Private events and member benefits',
  ];
  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(profileNotificationsProvider);
    const keys = ['orderUpdates', 'privateStyling', 'newCollections', 'offers'];
    return StorePageScaffold(
      title: 'Notifications',
      child: Column(
        children: [
          const PageIntro(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Choose what you hear from us about',
          ),
          notifications.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Column(
              children: [
                Text(apiErrorMessage(error)),
                TextButton(
                  onPressed: () => ref.invalidate(profileNotificationsProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
            data: (settings) => Column(
              children: List.generate(
                _titles.length,
                (index) => SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 22),
                  title: Text(
                    _titles[index],
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    _subtitles[index],
                    style: const TextStyle(
                      fontSize: 10,
                      color: StoreColors.muted,
                    ),
                  ),
                  value: settings[keys[index]] as bool? ?? false,
                  activeThumbColor: StoreColors.olive,
                  onChanged: (value) => _saveNotification(keys[index], value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotification(String key, bool value) async {
    try {
      await ref.read(accountRepositoryProvider).updateProfile({
        'notifications': {key: value},
      });
      ref.invalidate(profileNotificationsProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Help & Support',
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'HOW CAN WE HELP?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: StoreColors.olive,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We’re here for you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, fontFamily: 'serif'),
            ),
            const SizedBox(height: 22),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search help topics',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            const _SettingsRow(
              title: 'Chat with us',
              subtitle: 'Usually replies instantly',
              onTap: _noop,
            ),
            const _SettingsRow(
              title: 'Ask your stylist',
              subtitle: 'Personal wardrobe advice',
              onTap: _noop,
            ),
            const SizedBox(height: 10),
            ...[
              'Orders & delivery',
              'Returns & exchanges',
              'Sizing & fit',
              'Payments',
              'Product care',
            ].map(
              (topic) => ListTile(
                title: Text(topic, style: const TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SimpleInfoPage(
                      title: topic,
                      message:
                          'For help with $topic, chat with our client support team.',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Or call us on +234 1 888 0456\nMon–Sat, 9am–7pm WAT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                height: 1.7,
                color: StoreColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SimpleInfoPage extends StatelessWidget {
  const SimpleInfoPage({super.key, required this.title, required this.message});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: title,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: StoreColors.muted),
        ),
      ),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        color: title == 'Delete account' ? Colors.brown : StoreColors.ink,
      ),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 10, color: StoreColors.muted),
    ),
    trailing: const Icon(Icons.chevron_right, size: 18),
  );
}

void _noop() {}
