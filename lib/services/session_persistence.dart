import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session.dart';
import '../models/player.dart';

class SessionPersistence {
  static const _key = 'session_v1';

  static Future<void> save(Session? session) async {
    final prefs = await SharedPreferences.getInstance();
    if (session == null) {
      await prefs.remove(_key);
      return;
    }
    final json = jsonEncode({
      'players': session.players.map((p) => p.toJson()).toList(),
    });
    await prefs.setString(_key, json);
  }

  static Future<Session?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final players = (json['players'] as List)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList();
      if (players.length < 2) return null;
      return Session(players: players);
    } catch (_) {
      return null;
    }
  }
}