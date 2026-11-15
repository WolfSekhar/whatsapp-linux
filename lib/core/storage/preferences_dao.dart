import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../domain/models/app_preferences.dart';
import 'local_database.dart';

/// Data Access Object for local app preferences persistence in SQLite.
class PreferencesDao {
  final Database? _injectedDb;
  Map<String, dynamic>? _memoryFallback;
  bool _tableEnsured = false;

  PreferencesDao([this._injectedDb]);

  Future<Database?> _getDb() async {
    if (_injectedDb != null) return _injectedDb;
    try {
      return await LocalDatabase.database;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureTable(Database db) async {
    if (_tableEnsured) return;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    _tableEnsured = true;
  }

  /// Retrieves persisted preferences, or default preferences if unset.
  Future<AppPreferences> getPreferences() async {
    try {
      final db = await _getDb();
      if (db == null) {
        if (_memoryFallback != null) {
          return AppPreferences.fromJson(_memoryFallback!);
        }
        return const AppPreferences();
      }

      await _ensureTable(db);
      final rows = await db.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['app_preferences'],
        limit: 1,
      );

      if (rows.isNotEmpty) {
        final valStr = rows.first['value'] as String?;
        if (valStr != null && valStr.isNotEmpty) {
          final map = jsonDecode(valStr) as Map<String, dynamic>;
          return AppPreferences.fromJson(map);
        }
      }
    } catch (_) {
      if (_memoryFallback != null) {
        return AppPreferences.fromJson(_memoryFallback!);
      }
    }
    return const AppPreferences();
  }

  /// Persists [preferences] to SQLite, falling back to memory if DB is unavailable.
  Future<void> savePreferences(AppPreferences preferences) async {
    final jsonMap = preferences.toJson();
    _memoryFallback = jsonMap;

    try {
      final db = await _getDb();
      if (db == null) return;

      await _ensureTable(db);
      final valStr = jsonEncode(jsonMap);
      await db.insert(
        'preferences',
        {'key': 'app_preferences', 'value': valStr},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Memory fallback is already set above
    }
  }
}
