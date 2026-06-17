import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Append-only Log aller eingetragenen Ergebnisse, persistiert in
/// `shared_preferences`. Eine Zeile pro Eintragung, chronologisch
/// (neueste zuletzt). [eintraege] treibt die Anzeige live an.
class ErgebnisLog {
  static const String _schluessel = 'ergebnis_log';

  static late ErgebnisLog instance;

  final SharedPreferences _prefs;
  final ValueNotifier<List<String>> eintraege;

  ErgebnisLog._(
    this._prefs,
  ) : eintraege = ValueNotifier<List<String>>(
        _prefs.getStringList(_schluessel) ?? <String>[],
      );

  static void initialisieren(
    SharedPreferences prefs,
  ) {
    instance = ErgebnisLog._(
      prefs,
    );
  }

  Future<void> eintragen(
    String zeile,
  ) async {
    final List<String> neu = <String>[
      ...eintraege.value,
      zeile,
    ];
    eintraege.value = neu;
    await _prefs.setStringList(
      _schluessel,
      neu,
    );
  }

  Future<void> leeren() async {
    eintraege.value = <String>[];
    await _prefs.remove(
      _schluessel,
    );
  }
}
