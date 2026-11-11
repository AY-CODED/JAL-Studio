import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    id: json['_id'] as String,
    subject: json['subject'] as String,
    message: json['message'] as String,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final String id;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;
}

final supportTicketsProvider = FutureProvider<List<SupportTicket>>((ref) async {
  final response = await ref
      .watch(apiClientProvider)
      .dio
      .get<Map<String, dynamic>>('/support/tickets');
  return (response.data!['data'] as List<dynamic>)
      .map((item) => SupportTicket.fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
});

class SupportPage extends ConsumerStatefulWidget {
  const SupportPage({super.key});

  @override
  ConsumerState<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends ConsumerState<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(apiClientProvider)
          .dio
          .post<void>(
            '/support/tickets',
            data: {
              'subject': _subject.text.trim(),
              'message': _message.text.trim(),
            },
          );
      _subject.clear();
      _message.clear();
      ref.invalidate(supportTicketsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your message was sent to support.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(apiErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'Help & Support',
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const PageIntro(
          icon: Icons.support_agent,
          title: 'How can we help?',
          subtitle: 'Send our team a message and follow your requests here.',
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    validator: (value) => (value?.trim().length ?? 0) < 3
                        ? 'Please enter a short subject'
                        : null,
                  ),
                  TextFormField(
                    controller: _message,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'How can we help?',
                    ),
                    validator: (value) => (value?.trim().length ?? 0) < 10
                        ? 'Please provide a little more detail'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _sending ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: StoreColors.ink,
                      ),
                      child: Text(_sending ? 'Sending…' : 'Contact support'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your support requests',
          style: TextStyle(fontFamily: 'serif', fontSize: 22),
        ),
        const SizedBox(height: 8),
        ref
            .watch(supportTicketsProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                children: [
                  Text(apiErrorMessage(error)),
                  TextButton(
                    onPressed: () => ref.invalidate(supportTicketsProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
              data: (tickets) => tickets.isEmpty
                  ? const Text('You have no open requests.')
                  : Column(
                      children: tickets
                          .map(
                            (ticket) => Card(
                              child: ListTile(
                                title: Text(ticket.subject),
                                subtitle: Text(
                                  '${ticket.message}\n${ticket.createdAt.toLocal()}',
                                ),
                                isThreeLine: true,
                                trailing: Text(
                                  ticket.status.replaceAll('_', ' '),
                                  style: const TextStyle(
                                    color: StoreColors.olive,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
      ],
    ),
  );
}
