import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/services/liga_speicher.dart';

/// Speichert eine [Liga] als JSONB-Zeile in der Supabase-Tabelle `ligas`.
///
/// Erwartetes Schema:
/// ```sql
/// CREATE TABLE ligas (
///   name  TEXT PRIMARY KEY,
///   daten JSONB NOT NULL
/// );
/// ```
///
/// Initialisierung in main():
/// ```dart
/// await Supabase.initialize(url: '...', anonKey: '...');
/// final speicher = LigaSpeicherSupabase(Supabase.instance.client);
/// ```
class LigaSpeicherSupabase extends LigaSpeicher {
  final SupabaseClient _client;
  static const String _tabelle = 'ligas';

  LigaSpeicherSupabase(
    this._client,
  );

  @override
  Future<void> speichern(
    Liga liga,
  ) async {
    print('supa upsert');
    await _client.from(_tabelle).upsert(
      {
        'name': liga.name,
        'daten': liga.toJson(),
      },
    );
  }

  @override
  Future<Liga?> laden(
    String name,
  ) async {
    print('supa load');
    final Map<String, dynamic>? row = await _client
        .from(_tabelle)
        .select('daten')
        .eq(
          'name',
          name,
        )
        .maybeSingle();
    if (row == null) {
      return null;
    }
    return Liga.fromJson(
      row['daten'] as Map<String, dynamic>,
    );
  }

  @override
  Stream<Liga?> aenderungen(
    String name,
  ) {
    print('supa aenderung');
    return _client
        .from(_tabelle)
        .stream(
          primaryKey: ['name'],
        )
        .eq(
          'name',
          name,
        )
        .map((rows) {
          if (rows.isEmpty) {
            return null;
          }
          return Liga.fromJson(
            rows.first['daten'] as Map<String, dynamic>,
          );
        });
  }

}
