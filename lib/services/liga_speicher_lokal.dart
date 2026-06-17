import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/services/liga_speicher.dart';

/// Lokaler Fallback-Speicher: legt eine [Liga] als JSON-String in
/// `shared_preferences` ab (Key `liga:<name>`). Dient als Offline-Cache,
/// wenn Supabase nicht erreichbar ist.
class LigaSpeicherLokal extends LigaSpeicher {
  final SharedPreferences _prefs;

  LigaSpeicherLokal(
    this._prefs,
  );

  static String _schluessel(
    String name,
  ) {
    return 'liga:$name';
  }

  /// Synchron gecachte Kopie (fuer Sofort-Anzeige beim Start), oder null.
  Liga? letzteKopie(
    String name,
  ) {
    final String? roh = _prefs.getString(
      _schluessel(name),
    );
    if (roh == null) {
      return null;
    }
    return Liga.fromJson(
      jsonDecode(roh) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> speichern(
    Liga liga,
  ) async {
    await _prefs.setString(
      _schluessel(liga.name),
      jsonEncode(liga.toJson()),
    );
  }

  @override
  Stream<Liga?> aenderungen(
    String name,
  ) async* {
    yield letzteKopie(name);
  }
}
