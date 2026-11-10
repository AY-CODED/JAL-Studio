import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = 'customer',
    this.phone,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    role: json['role'] as String? ?? 'customer',
    phone: json['phone'] as String?,
  );

  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
}

class AuthRepository {
  const AuthRepository({required this.client, required this.tokenStorage});

  final ApiClient client;
  final TokenStorage tokenStorage;

  Future<AuthUser?> restoreSession() async {
    final token = await tokenStorage.read();
    if (token == null) return null;
    try {
      final response = await client.dio.get<Map<String, dynamic>>('/auth/me');
      return AuthUser.fromJson(
        response.data!['data']['user'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await tokenStorage.clear();
        return null;
      }
      rethrow;
    }
  }

  Future<AuthUser> signIn({required String email, required String password}) =>
      _authenticate('/auth/login', {'email': email, 'password': password});

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) => _authenticate('/auth/register', {
    'fullName': fullName,
    'email': email,
    'password': password,
  });

  Future<AuthUser> _authenticate(String path, Map<String, Object> body) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      path,
      data: body,
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    await tokenStorage.write(data['token'] as String);
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> signOut() => tokenStorage.clear();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    client: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
