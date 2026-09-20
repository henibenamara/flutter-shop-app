import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/session_model.dart';

abstract interface class AuthLocalDataSource {
  Future<SessionModel?> readSession();

  Future<void> saveSession(SessionModel session);

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  static const _key = 'auth.session';

  final SharedPreferences _prefs;

  @override
  Future<SessionModel?> readSession() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return SessionModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on FormatException {
      await _prefs.remove(_key);
      return null;
    } on TypeError {
      await _prefs.remove(_key);
      return null;
    }
  }

  @override
  Future<void> saveSession(SessionModel session) async {
    final saved = await _prefs.setString(_key, jsonEncode(session.toJson()));
    if (!saved) throw const StorageException('Could not save your session.');
  }

  @override
  Future<void> clearSession() async {
    final removed = await _prefs.remove(_key);
    if (!removed) throw const StorageException('Could not sign you out.');
  }
}
