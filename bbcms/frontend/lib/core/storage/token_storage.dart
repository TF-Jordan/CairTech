import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccessKey = 'bbcms.accessToken';
const _kRefreshKey = 'bbcms.refreshToken';

/// Token storage with in-memory fallback when the OS keyring is unavailable
/// (Linux sans libsecret/gnome-keyring, environnements desktop minimaux, etc.).
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static final Map<String, String> _memoryFallback = {};
  static bool _useFallback = false;

  Future<String?> readAccess() => _read(_kAccessKey);
  Future<String?> readRefresh() => _read(_kRefreshKey);

  Future<void> writeTokens({
    required String access,
    required String refresh,
  }) async {
    await _write(_kAccessKey, access);
    await _write(_kRefreshKey, refresh);
  }

  Future<void> clear() async {
    await _delete(_kAccessKey);
    await _delete(_kRefreshKey);
  }

  Future<String?> _read(String key) async {
    if (_useFallback) return _memoryFallback[key];
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('[TokenStorage] secure read failed → in-memory fallback: $e');
      _useFallback = true;
      return _memoryFallback[key];
    }
  }

  Future<void> _write(String key, String value) async {
    if (_useFallback) {
      _memoryFallback[key] = value;
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[TokenStorage] secure write failed → in-memory fallback: $e');
      _useFallback = true;
      _memoryFallback[key] = value;
    }
  }

  Future<void> _delete(String key) async {
    _memoryFallback.remove(key);
    if (_useFallback) return;
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('[TokenStorage] secure delete failed: $e');
      _useFallback = true;
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});
