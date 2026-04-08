import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/model/team.dart';

class Liga {
  final String name;
  final List<Team> teams;
  final List<Spieltag> hinrunde;
  final List<Spieltag> rueckrunde;

  const Liga({
    required this.name,
    required this.teams,
    required this.hinrunde,
    required this.rueckrunde,
  });

  List<Spieltag> get alleSpieltage => [...hinrunde, ...rueckrunde];

  List<Begegnung> get begegnungen =>
      alleSpieltage.expand((st) => st.begegnungen).toList();

  /// Erstellt den Spielplan per Round-Robin.
  /// Bei ungerader Teamanzahl erhält ein Team pro Spieltag ein Freilos.
  factory Liga.mitSpielplan({
    required String name,
    required List<Team> teams,
  }) {
    // Bei ungerader Anzahl: null als Platzhalter für Freilos einfügen
    final List<Team?> rot = teams.length.isOdd
        ? [null, ...teams]
        : List<Team?>.from(teams);
    final m = rot.length; // immer gerade
    final rounds = m - 1;

    final hinrunde = <Spieltag>[];
    final rueckrunde = <Spieltag>[];
    int begId = 1;

    for (int round = 0; round < rounds; round++) {
      final hinBeg = <Begegnung>[];
      final rueckBeg = <Begegnung>[];
      Team? freilos;

      for (int i = 0; i < m ~/ 2; i++) {
        final heim = rot[i];
        final gast = rot[m - 1 - i];

        if (heim == null) {
          freilos = gast;
          continue;
        }
        if (gast == null) {
          freilos = heim;
          continue;
        }

        hinBeg.add(Begegnung(
          id: 'b${begId++}',
          heimTeam: heim,
          gastTeam: gast,
          istHinrunde: true,
        ),);
        rueckBeg.add(Begegnung(
          id: 'b${begId++}',
          heimTeam: gast,
          gastTeam: heim,
          istHinrunde: false,
        ),);
      }

      hinrunde.add(Spieltag(
        nummer: round + 1,
        istHinrunde: true,
        freilos: freilos,
        begegnungen: hinBeg,
      ),);
      rueckrunde.add(Spieltag(
        nummer: rounds + round + 1,
        istHinrunde: false,
        freilos: freilos,
        begegnungen: rueckBeg,
      ),);

      // Rotation: Position 0 fix, letztes Element rückt auf Position 1
      final last = rot[m - 1];
      for (int i = m - 1; i > 1; i--) {
        rot[i] = rot[i - 1];
      }
      rot[1] = last;
    }

    return Liga(
      name: name,
      teams: teams,
      hinrunde: hinrunde,
      rueckrunde: rueckrunde,
    );
  }

  // ── Mutationen ───────────────────────────────────────────────────

  bool get hatErgebnisse => begegnungen.any(
    (b) => b.spiele.whereType<Spiel>().any((s) => s.saetze.isNotEmpty),
  );

  Liga mitTeamUmbenennt(String teamId, String neuerName) {
    final altes = teams.firstWhere((t) => t.id == teamId);
    final neues = Team(id: altes.id, name: neuerName, spieler: altes.spieler);

    Spieltag aktualisiereTag(Spieltag st) => Spieltag(
      nummer: st.nummer,
      istHinrunde: st.istHinrunde,
      freilos: st.freilos?.id == teamId ? neues : st.freilos,
      begegnungen: st.begegnungen
          .map(
            (b) => Begegnung(
              id: b.id,
              heimTeam: b.heimTeam.id == teamId ? neues : b.heimTeam,
              gastTeam: b.gastTeam.id == teamId ? neues : b.gastTeam,
              istHinrunde: b.istHinrunde,
              spiele: b.spiele,
            ),
          )
          .toList(),
    );

    return Liga(
      name: name,
      teams: teams.map((t) => t.id == teamId ? neues : t).toList(),
      hinrunde: hinrunde.map(aktualisiereTag).toList(),
      rueckrunde: rueckrunde.map(aktualisiereTag).toList(),
    );
  }

  Liga mitTeamHinzugefuegt(Team neuesTeam) => Liga.mitSpielplan(
    name: name,
    teams: [...teams, neuesTeam],
  );

  Liga mitSpielerUmbenennt(String teamId, Spieler aktualisiert) {
    Spiel spielerErsetzen(Spiel spiel) => switch (spiel) {
      Einzel(:final heimSpieler, :final gastSpieler, :final satz) => Einzel(
        heimSpieler: heimSpieler?.id == aktualisiert.id
            ? aktualisiert
            : heimSpieler,
        gastSpieler: gastSpieler?.id == aktualisiert.id
            ? aktualisiert
            : gastSpieler,
        satz: satz,
      ),
      Doppel(:final heimSpieler, :final gastSpieler, :final saetze) => Doppel(
        heimSpieler: heimSpieler
            .map((s) => s.id == aktualisiert.id ? aktualisiert : s)
            .toList(),
        gastSpieler: gastSpieler
            .map((s) => s.id == aktualisiert.id ? aktualisiert : s)
            .toList(),
        saetze: saetze,
      ),
    };

    Spieltag tagAktualisieren(Spieltag st) => Spieltag(
      nummer: st.nummer,
      istHinrunde: st.istHinrunde,
      freilos: st.freilos,
      begegnungen: st.begegnungen
          .map(
            (b) => Begegnung(
              id: b.id,
              heimTeam: b.heimTeam,
              gastTeam: b.gastTeam,
              istHinrunde: b.istHinrunde,
              spiele: b.spiele
                  .map((s) => s != null ? spielerErsetzen(s) : null)
                  .toList(),
            ),
          )
          .toList(),
    );

    return Liga(
      name: name,
      teams: teams
          .map(
            (t) => t.id != teamId
                ? t
                : Team(
                    id: t.id,
                    name: t.name,
                    spieler: t.spieler
                        .map(
                          (s) => s.id == aktualisiert.id ? aktualisiert : s,
                        )
                        .toList(),
                  ),
          )
          .toList(),
      hinrunde: hinrunde.map(tagAktualisieren).toList(),
      rueckrunde: rueckrunde.map(tagAktualisieren).toList(),
    );
  }

  Liga mitSpielerHinzugefuegt(String teamId, Spieler neuerSpieler) => Liga(
    name: name,
    teams: teams
        .map(
          (t) => t.id != teamId
              ? t
              : Team(
                  id: t.id,
                  name: t.name,
                  spieler: [...t.spieler, neuerSpieler],
                ),
        )
        .toList(),
    hinrunde: hinrunde,
    rueckrunde: rueckrunde,
  );

  Liga mitSpielerEntfernt(String teamId, String spielerId) => Liga(
    name: name,
    teams: teams
        .map(
          (t) => t.id != teamId
              ? t
              : Team(
                  id: t.id,
                  name: t.name,
                  spieler: t.spieler.where((s) => s.id != spielerId).toList(),
                ),
        )
        .toList(),
    hinrunde: hinrunde,
    rueckrunde: rueckrunde,
  );

  Liga mitTeamEntfernt(String teamId) => Liga.mitSpielplan(
    name: name,
    teams: teams.where((t) => t.id != teamId).toList(),
  );

  /// Gibt eine neue [Liga] zurück, bei der [begegnung] (per ID) ersetzt ist.
  Liga mitBegegnung(Begegnung begegnung) => Liga(
    name: name,
    teams: teams,
    hinrunde:
        hinrunde.map((st) => st.mitBegegnung(begegnung)).toList(),
    rueckrunde:
        rueckrunde.map((st) => st.mitBegegnung(begegnung)).toList(),
  );

  // ── Statistiken pro Team ─────────────────────────────────────────

  Iterable<Begegnung> abgeschlossen(Team team) => begegnungen.where(
    (b) =>
        b.istAbgeschlossen && (b.heimTeam == team || b.gastTeam == team),
  );

  int ligapunkteVon(Team team) => abgeschlossen(team).fold(0, (sum, b) {
    if (b.heimTeam == team) {
      return sum + b.ligapunkteHeim;
    }
    return sum + b.ligapunkteGast;
  });

  int siegeVon(Team team) {
    int siege = 0;
    for (final Begegnung b in abgeschlossen(team)) {
      for (final Spiel? s in b.spiele) {
        if (s != null) {
          for (final Satz a in s.saetze) {
            if (b.heimTeam == team) {
              siege += (a.punkteHeim == 2 ? 1 : 0);
            } else if (b.gastTeam == team) {
              siege += (a.punkteGast == 2 ? 1 : 0);
            }
          }
        }
      }
    }
    return siege;
  }

  int niederlagenVon(Team team) {
    int niederlagen = 0;
    for (final Begegnung b in abgeschlossen(team)) {
      for (final Spiel? s in b.spiele) {
        if (s != null) {
          for (final Satz a in s.saetze) {
            if (b.heimTeam == team) {
              niederlagen += (a.punkteHeim == 0 ? 1 : 0);
            } else if (b.gastTeam == team) {
              niederlagen += (a.punkteGast == 0 ? 1 : 0);
            }
          }
        }
      }
    }
    return niederlagen;
  }

  int unentschiedenVon(Team team) {
    int unentschieden = 0;
    for (final Begegnung b in abgeschlossen(team)) {
      for (final Spiel? s in b.spiele) {
        if (s != null) {
          for (final Satz a in s.saetze) {
            if (b.heimTeam == team) {
              unentschieden += (a.punkteHeim == 1 ? 1 : 0);
            } else if (b.gastTeam == team) {
              unentschieden += (a.punkteGast == 1 ? 1 : 0);
            }
          }
        }
      }
    }
    return unentschieden;
  }

  int toreVon(Team team) {
    int fuer = 0;
    for (final b in abgeschlossen(team)) {
      if (b.heimTeam == team) {
        fuer += b.toreHeim;
      } else if (b.gastTeam == team) {
        fuer += b.toreGast;
      }
    }
    return fuer;
  }

  int gegenToreVon(Team team) {
    int gegen = 0;
    for (final b in abgeschlossen(team)) {
      if (b.heimTeam == team) {
        gegen += b.toreGast;
      } else if (b.gastTeam == team) {
        gegen += b.toreHeim;
      }
    }
    return gegen;
  }

  int torDifferenzVon(Team team) => toreVon(team) - gegenToreVon(team);

  int punkteDifferenzVon(Team team) {
    int fuer = 0;
    int gegen = 0;
    for (final Begegnung b in abgeschlossen(team)) {
      for (final Spiel? s in b.spiele) {
        if (s != null) {
          if (b.heimTeam == team) {
            fuer += s.punkteHeim;
            gegen += s.punkteGast;
          } else if (b.gastTeam == team) {
            fuer += s.punkteGast;
            gegen += s.punkteHeim;
          }
        }
      }
    }
    return fuer - gegen;
  }

  int _direkterVergleich(Team a, Team b) {
    int punkteA = 0;
    int punkteB = 0;
    for (final beg in begegnungen) {
      if (!beg.istAbgeschlossen) {
        continue;
      }
      if (beg.heimTeam == a && beg.gastTeam == b) {
        punkteA += beg.ligapunkteHeim;
        punkteB += beg.ligapunkteGast;
      } else if (beg.heimTeam == b && beg.gastTeam == a) {
        punkteB += beg.ligapunkteHeim;
        punkteA += beg.ligapunkteGast;
      }
    }
    return punkteA.compareTo(punkteB);
  }

  // ── Tabelle ──────────────────────────────────────────────────────

  /// Teams sortiert nach:
  /// 1. Ligapunkte, 2. Punktedifferenz, 3. Tordifferenz,
  /// 4. Direkter Vergleich.
  List<Team> get tabelle {
    final sorted = List<Team>.from(teams)
      ..sort((a, b) {
        final lp = ligapunkteVon(b).compareTo(ligapunkteVon(a));
        if (lp != 0) {
          return lp;
        }
        final sv = punkteDifferenzVon(b).compareTo(punkteDifferenzVon(a));
        if (sv != 0) {
          return sv;
        }
        final tv = torDifferenzVon(b).compareTo(torDifferenzVon(a));
        if (tv != 0) {
          return tv;
        }
        return _direkterVergleich(b, a);
      });
    return sorted;
  }

  // ── JSON ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'name': name,
    'teams': teams.map((t) => t.toJson()).toList(),
    'hinrunde': hinrunde.map((st) => st.toJson()).toList(),
    'rueckrunde': rueckrunde.map((st) => st.toJson()).toList(),
  };

  factory Liga.fromJson(Map<String, dynamic> json) {
    final teams = (json['teams'] as List<dynamic>)
        .map((t) => Team.fromJson(t as Map<String, dynamic>))
        .toList();
    final teamsById = {for (final t in teams) t.id: t};

    return Liga(
      name: json['name'] as String,
      teams: teams,
      hinrunde: (json['hinrunde'] as List<dynamic>)
          .map(
            (st) => Spieltag.fromJson(
              st as Map<String, dynamic>,
              teamsById,
            ),
          )
          .toList(),
      rueckrunde: (json['rueckrunde'] as List<dynamic>)
          .map(
            (st) => Spieltag.fromJson(
              st as Map<String, dynamic>,
              teamsById,
            ),
          )
          .toList(),
    );
  }
}
