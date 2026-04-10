import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';
import 'package:ue45x/model/tisch.dart';

/// Reihenfolge der Spiele in einer Begegnung: D1, E1, D2, E2, D3, E3, D4.
enum SpielSlot {
  d1,
  e1,
  d2,
  e2,
  d3,
  e3,
  d4,
}

extension SpielSlotLabel on SpielSlot {
  String get label => switch (this) {
    SpielSlot.d1 => 'D1',
    SpielSlot.e1 => 'E1',
    SpielSlot.d2 => 'D2',
    SpielSlot.e2 => 'E2',
    SpielSlot.d3 => 'D3',
    SpielSlot.e3 => 'E3',
    SpielSlot.d4 => 'D4',
  };

  bool get istDoppel =>
      this == SpielSlot.d1 ||
      this == SpielSlot.d2 ||
      this == SpielSlot.d3 ||
      this == SpielSlot.d4;
}

/// Eine Begegnung zwischen zwei Teams (Hin- oder Rückrunde).
///
/// Enthält 7 Spiele in fester Reihenfolge: D1, E1, D2, E2, D3, E3, D4.
/// Pro Begegnung sind max. 22 Punkte zu vergeben (11 Sätze × 2).
class Begegnung {
  final String id;
  final Team heimTeam;
  final Team gastTeam;
  final bool istHinrunde;
  final Tisch? tisch;

  /// 7 Slots, Index entspricht [SpielSlot].
  /// null = Spiel noch nicht eingetragen.
  final List<Spiel?> spiele;

  Begegnung({
    required this.id,
    required this.heimTeam,
    required this.gastTeam,
    required this.istHinrunde,
    this.tisch,
    List<Spiel?>? spiele,
  }) : spiele =
           spiele ??
           List.filled(
             SpielSlot.values.length,
             null,
           );

  Spiel? spielAt(SpielSlot slot) => spiele[slot.index];

  Begegnung mitTisch(Tisch? neuerTisch) => Begegnung(
    id: id,
    heimTeam: heimTeam,
    gastTeam: gastTeam,
    istHinrunde: istHinrunde,
    tisch: neuerTisch,
    spiele: spiele,
  );

  /// Gibt eine neue [Begegnung] zurück, bei der [slot] mit [spiel] belegt ist.
  Begegnung mitSpiel(
    SpielSlot slot,
    Spiel spiel,
  ) {
    final neueSpiele = List<Spiel?>.from(spiele);
    neueSpiele[slot.index] = spiel;
    return Begegnung(
      id: id,
      heimTeam: heimTeam,
      gastTeam: gastTeam,
      istHinrunde: istHinrunde,
      tisch: tisch,
      spiele: neueSpiele,
    );
  }

  // ── Satzpunkte ───────────────────────────────────────────────────

  int get satzpunkteHeim => spiele.whereType<Spiel>().fold(0, (s, sp) {
    return s + sp.punkteHeim;
  });

  int get satzpunkteGast => spiele.whereType<Spiel>().fold(0, (s, sp) {
    return s + sp.punkteGast;
  });

  bool get istAbgeschlossen => spiele.every((s) {
    return s != null && s.istAbgeschlossen;
  });

  // ── Ligapunkte ───────────────────────────────────────────────────

  int get ligapunkteHeim {
    if (!istAbgeschlossen) {
      return 0;
    }
    if (satzpunkteHeim > satzpunkteGast) {
      return 2;
    }
    if (satzpunkteHeim == satzpunkteGast) {
      return 1;
    }
    return 0;
  }

  int get ligapunkteGast {
    if (!istAbgeschlossen) {
      return 0;
    }
    if (satzpunkteGast > satzpunkteHeim) {
      return 2;
    }
    if (satzpunkteGast == satzpunkteHeim) {
      return 1;
    }
    return 0;
  }

  // ── Tore ─────────────────────────────────────────────────────────

  int get toreHeim => spiele
      .whereType<Spiel>()
      .expand((sp) {
        return sp.saetze;
      })
      .fold(0, (sum, s) {
        return sum + s.heimTore;
      });

  int get toreGast => spiele
      .whereType<Spiel>()
      .expand((sp) {
        return sp.saetze;
      })
      .fold(0, (sum, s) {
        return sum + s.gastTore;
      });

  // ── JSON ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'heim': heimTeam.id,
    'gast': gastTeam.id,
    'hin': istHinrunde,
    'tischId': tisch?.id,
    'spiele': spiele.map((s) {
      return s?.toJson();
    }).toList(),
  };

  factory Begegnung.fromJson(
    Map<String, dynamic> json,
    Map<String, Team> teamsById,
    Map<String, Tisch> tischeById,
    Map<String, Spieler> spielerById,
  ) {
    final String? tischId = json['tischId'] as String?;
    return Begegnung(
      id: json['id'] as String,
      heimTeam: teamsById[json['heim']]!,
      gastTeam: teamsById[json['gast']]!,
      istHinrunde: json['hin'] as bool,
      tisch: tischId != null ? tischeById[tischId] : null,
      spiele: (json['spiele'] as List<dynamic>).map((s) {
        return s != null
            ? Spiel.fromJson(
                s as Map<String, dynamic>,
                spielerById,
              )
            : null;
      }).toList(),
    );
  }

  @override
  String toString() =>
      '${heimTeam.name} vs ${gastTeam.name} (${istHinrunde ? "Hin" : "Rück"})';
}
