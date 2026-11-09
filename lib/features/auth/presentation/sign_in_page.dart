import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error_message.dart';
import '../../../core/theme/store_colors.dart';
import '../../../core/widgets/store_components.dart';
import '../providers/auth_provider.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final controller = ref.read(authProvider.notifier);
    if (_isRegistering) {
      await controller.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await controller.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    final state = ref.read(authProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(apiErrorMessage(state.error!))));
      return;
    }
    if (state.asData?.value != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => StorePageScaffold(
    title: 'EKŌ',
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageIntro(
              icon: Icons.person_outline,
              title: _isRegistering ? 'Create your account' : 'Welcome back',
              subtitle: _isRegistering
                  ? 'Join EKŌ for a more personal wardrobe.'
                  : 'Sign in to access your bag and member profile.',
            ),
            if (_isRegistering)
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) =>
                    (value?.trim().length ?? 0) < 2 ? 'Enter your name' : null,
              ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Email address'),
              validator: (value) {
                final email = value?.trim() ?? '';
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                    ? null
                    : 'Enter a valid email address';
              },
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                helperText: _isRegistering
                    ? 'Use at least 10 characters'
                    : null,
              ),
              validator: (value) =>
                  (value?.length ?? 0) < (_isRegistering ? 10 : 1)
                  ? _isRegistering
                        ? 'Password must be at least 10 characters'
                        : 'Enter your password'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.ink,
                padding: const EdgeInsets.all(16),
              ),
              child: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isRegistering ? 'Create account' : 'Sign in'),
            ),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() => _isRegistering = !_isRegistering),
              child: Text(
                _isRegistering
                    ? 'Already a member? Sign in'
                    : 'New to EKŌ? Create an account',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
