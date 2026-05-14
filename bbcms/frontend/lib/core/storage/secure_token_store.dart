import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class SecureTokenStore {
  static const _kAccess = 'bbcms.access';
  static const _kRefresh = 'bbcms.refresh';
  static const _kDeviceId = 'bbcms.deviceId';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> save(TokenPair pair) async {
    await _storage.write(key: _kAccess, value: pair.accessToken);
    await _storage.write(key: _kRefresh, value: pair.refreshToken);
  }

  Future<TokenPair?> read() async {
    final String? access = await _storage.read(key: _kAccess);
    final String? refresh = await _storage.read(key: _kRefresh);
    if (access == null || refresh == null) return null;
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  Future<String> deviceId() async {
    final String? existing = await _storage.read(key: _kDeviceId);
    if (existing != null) return existing;
    final String fresh = DateTime.now().microsecondsSinceEpoch.toRadixString(36) +
        '-' +
        (1000 + (DateTime.now().millisecond * 31)).toRadixString(36);
    await _storage.write(key: _kDeviceId, value: fresh);
    return fresh;
  }
}

final Provider<SecureTokenStore> tokenStoreProvider =
    Provider<SecureTokenStore>((Ref ref) => SecureTokenStore());
