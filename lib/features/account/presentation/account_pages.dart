import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../../../core/utils/currency.dart';
import '../data/account_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart_checkout/data/order_repository.dart';

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

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).asData?.value;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(accountRepositoryProvider).updateProfile({
        'fullName': _name.text.trim(),
        'phone': _phone.text.trim(),
      });
      await ref.read(authProvider.notifier).refreshProfile();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile changes saved')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).asData?.value;
    return StorePageScaffold(
      title: 'Edit Profile',
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const PageIntro(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Your member information',
              ),
              CircleAvatar(
                radius: 42,
                backgroundColor: StoreColors.ink,
                child: Text(
                  (user?.fullName.isNotEmpty == true
                          ? user!.fullName[0].toUpperCase()
                          : '?')
                      .toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'serif',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'FULL NAME'),
                validator: (value) =>
                    (value?.trim().length ?? 0) < 2 ? 'Enter your name' : null,
              ),
              TextFormField(
                initialValue: user?.email ?? '',
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'EMAIL ADDRESS',
                  helperText: 'Email changes require account verification.',
                ),
              ),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'PHONE NUMBER'),
                validator: (value) => (value?.trim().length ?? 0) > 30
                    ? 'Phone number is too long'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: StoreColors.ink,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text(_saving ? 'Saving…' : 'Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => StorePageScaffold(
    title: 'Order History',
    child: ref
        .watch(ordersProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(apiErrorMessage(error)),
                TextButton(
                  onPressed: () => ref.invalidate(ordersProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
          data: (orders) => orders.isEmpty
              ? const Center(child: Text('Your orders will appear here.'))
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(ordersProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(18),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final canCancel =
                          ['paid', 'processing'].contains(order.status) ||
                          (order.status == 'pending_payment' &&
                              !order.hasPaymentSession);
                      final canReturn =
                          order.status == 'delivered' &&
                          order.returnStatus != 'requested' &&
                          order.returnStatus != 'approved';
                      return Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.orderNumber} · ${_formatDate(order.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: StoreColors.muted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      order.status
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatNaira(order.totalKobo),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${order.itemCount} item(s)'),
                              ...order.items.map(
                                (item) => Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.name} × ${item.quantity}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    if ([
                                      'paid',
                                      'processing',
                                      'shipped',
                                      'delivered',
                                    ].contains(order.status))
                                      TextButton(
                                        onPressed: () => _writeReview(
                                          context,
                                          ref,
                                          order,
                                          item,
                                        ),
                                        child: const Text('Review'),
                                      ),
                                  ],
                                ),
                              ),
                              if (order.returnStatus != null)
                                Text(
                                  'Return: ${order.returnStatus!.replaceAll('_', ' ')}',
                                ),
                              Wrap(
                                children: [
                                  if (canCancel)
                                    TextButton(
                                      onPressed: () => _submitReason(
                                        context,
                                        ref,
                                        title: 'Request cancellation',
                                        submit: (reason) => ref
                                            .read(orderRepositoryProvider)
                                            .requestCancellation(
                                              order.id,
                                              reason,
                                            ),
                                      ),
                                      child: const Text('Request cancellation'),
                                    ),
                                  if (canReturn)
                                    TextButton(
                                      onPressed: () => _submitReason(
                                        context,
                                        ref,
                                        title: 'Request a return',
                                        submit: (reason) => ref
                                            .read(orderRepositoryProvider)
                                            .requestReturn(order.id, reason),
                                      ),
                                      child: const Text('Request return'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _submitReason(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required Future<void> Function(String reason) submit,
  }) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null || reason.trim().length < 3) return;
    try {
      await submit(reason);
      ref.invalidate(ordersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request was submitted.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }

  Future<void> _writeReview(
    BuildContext context,
    WidgetRef ref,
    StoreOrder order,
    StoreOrderItem item,
  ) async {
    final review = await showDialog<(int, String)>(
      context: context,
      builder: (_) => const _ReviewDialog(),
    );
    if (review == null) return;
    try {
      await ref
          .read(orderRepositoryProvider)
          .requestReview(
            productId: item.productId,
            orderId: order.id,
            rating: review.$1,
            comment: review.$2,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your review.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    }
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _comment = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Write a review'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<int>(
          initialValue: _rating,
          decoration: const InputDecoration(labelText: 'Rating'),
          items: List.generate(
            5,
            (index) => DropdownMenuItem(
              value: 5 - index,
              child: Text('${5 - index} stars'),
            ),
          ),
          onChanged: (value) => setState(() => _rating = value ?? 5),
        ),
        TextField(
          controller: _comment,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Your experience'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_comment.text.trim().length >= 3) {
            Navigator.pop(context, (_rating, _comment.text.trim()));
          }
        },
        child: const Text('Submit'),
      ),
    ],
  );
}

class BodyMeasurementsPage extends ConsumerStatefulWidget {
  const BodyMeasurementsPage({super.key});

  @override
  ConsumerState<BodyMeasurementsPage> createState() =>
      _BodyMeasurementsPageState();
}

class _BodyMeasurementsPageState extends ConsumerState<BodyMeasurementsPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _values = {};
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final measurements = <String, Object>{};
    for (final entry in _values.entries) {
      if (entry.value.trim().isNotEmpty) {
        measurements[entry.key] = double.parse(entry.value.trim());
      }
    }
    setState(() => _saving = true);
    try {
      await ref.read(accountRepositoryProvider).updateProfile({
        'measurements': measurements,
      });
      ref.invalidate(accountProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Measurements saved securely.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Body Measurements',
    child: ref
        .watch(accountProfileProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(apiErrorMessage(error)),
                TextButton(
                  onPressed: () => ref.invalidate(accountProfileProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
          data: (profile) {
            final measurements =
                profile['measurements'] as Map<String, dynamic>? ?? const {};
            const fields = {
              'chestCm': 'Chest',
              'waistCm': 'Waist',
              'seatCm': 'Seat / hips',
              'shoulderCm': 'Shoulder',
              'sleeveCm': 'Sleeve',
              'insideLegCm': 'Inside leg',
            };
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const PageIntro(
                    icon: Icons.straighten,
                    title: 'Body Measurements',
                    subtitle: 'Save your fit profile in centimetres.',
                  ),
                  ...fields.entries.map((entry) {
                    final value = measurements[entry.key];
                    return TextFormField(
                      key: ValueKey('${entry.key}-${value ?? ''}'),
                      initialValue: value == null ? '' : '$value',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(labelText: entry.value),
                      validator: (input) {
                        if (input == null || input.trim().isEmpty) return null;
                        final number = double.tryParse(input.trim());
                        return number == null || number <= 0 || number > 300
                            ? 'Enter a measurement in centimetres'
                            : null;
                      },
                      onSaved: (input) => _values[entry.key] = input ?? '',
                    );
                  }),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: StoreColors.ink,
                    ),
                    child: Text(_saving ? 'Saving…' : 'Save measurements'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Measurements help you choose a size; always confirm garment-specific sizing with the seller.',
                    style: TextStyle(color: StoreColors.muted, fontSize: 12),
                  ),
                ],
              ),
            );
          },
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
