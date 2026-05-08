import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'sync_client.dart';
import 'sync_models.dart';

const _kDeviceIdKey = 'bbcms.deviceId';
String _cursorKey(SyncEntityKind k) => 'bbcms.sync.cursor.${k.apiValue}';

class SyncEngine {
  SyncEngine(this._client, this._prefs);

  final SyncClient _client;
  final SharedPreferences _prefs;

  String get deviceId {
    final existing = _prefs.getString(_kDeviceIdKey);
    if (existing != null) return existing;
    final id = const Uuid().v4();
    _prefs.setString(_kDeviceIdKey, id);
    return id;
  }

  DateTime? cursorOf(SyncEntityKind kind) {
    final s = _prefs.getString(_cursorKey(kind));
    return s == null ? null : DateTime.parse(s);
  }

  Future<void> _saveCursor(SyncEntityKind kind, DateTime when) async {
    await _prefs.setString(_cursorKey(kind), when.toUtc().toIso8601String());
  }

  /// Pulls a single page for [kind] and persists the cursor.
  Future<SyncBatch> pullOnce(SyncEntityKind kind) async {
    final batch = await _client.pull(
      kind: kind,
      deviceId: deviceId,
      since: cursorOf(kind),
    );
    await _saveCursor(kind, batch.cursorAdvancedTo);
    return batch;
  }

  /// Pulls all entity kinds sequentially. Returns total changes pulled.
  Future<int> pullAll() async {
    var total = 0;
    for (final kind in SyncEntityKind.values) {
      try {
        final batch = await pullOnce(kind);
        total += batch.count;
      } catch (_) {
        // best-effort: skip kinds the user has no permission for
      }
    }
    return total;
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((_) {
  return SharedPreferences.getInstance();
});

final syncEngineProvider = FutureProvider<SyncEngine>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SyncEngine(ref.watch(syncClientProvider), prefs);
});
