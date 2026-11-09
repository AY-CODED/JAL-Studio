import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

final authProvider = AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() {
    return ref.watch(authRepositoryProvider).restoreSession();
  }

  Future<void> signIn({required String email, required String password}) =>
      _run(
        () => ref
            .read(authRepositoryProvider)
            .signIn(email: email, password: password),
      );

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) => _run(
    () => ref
        .read(authRepositoryProvider)
        .register(fullName: fullName, email: email, password: password),
  );

  Future<void> _run(Future<AuthUser> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
