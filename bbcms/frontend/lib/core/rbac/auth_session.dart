import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../storage/token_storage.dart';

/// Decoded session info derived from the access JWT.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.userType,
    required this.permissions,
    this.bibleClubId,
  });

  final String userId;
  final String email;
  final String userType;
  final String? bibleClubId;
  final Set<String> permissions;

  bool can(String perm) => permissions.contains(perm);
  bool canAny(Iterable<String> perms) => perms.any(permissions.contains);

  static AuthSession? tryDecode(String accessToken) {
    if (accessToken.isEmpty) return null;
    if (JwtDecoder.isExpired(accessToken)) return null;
    final claims = JwtDecoder.decode(accessToken);
    final perms = (claims['permissions'] as List?)
            ?.whereType<String>()
            .toSet() ??
        const <String>{};
    return AuthSession(
      userId: claims['sub'] as String? ?? '',
      email: claims['email'] as String? ?? '',
      userType: claims['userType'] as String? ?? 'VISITOR',
      bibleClubId: claims['bibleClubId'] as String?,
      permissions: perms,
    );
  }
}

class AuthSessionNotifier extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final storage = ref.read(tokenStorageProvider);
    final token = await storage.readAccess();
    if (token == null) return null;
    return AuthSession.tryDecode(token);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(tokenStorageProvider);
      final token = await storage.readAccess();
      if (token == null) return null;
      return AuthSession.tryDecode(token);
    });
  }

  Future<void> clear() async {
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(null);
  }
}

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AuthSession?>(
  AuthSessionNotifier.new,
);
