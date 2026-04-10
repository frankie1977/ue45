import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/spieler_stats.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/model/team.dart';
import 'package:ue45x/model/tisch.dart';

class Liga {
  final String name;
  final List<Team> teams;
  final List<Spieltag> hinrunde;
  final List<Spieltag> rueckrunde;
  final List<Tisch> tische;

  const Liga({
    required this.name,
    required this.teams,
    required this.hinrunde,
    required this.rueckrunde,
    this.tische = const [],
  });

  List<Spieltag> get alleSpieltage => [...hinrunde, ...rueckrunde];

  List<Begegnung> get begegnungen => alleSpieltage.expand((st) {
    return st.begegnungen;
  }).toList();

  /// Erstellt den Spielplan per Round-Robin.
  /// Bei ungerader Teamanzahl erhält ein Team pro Spieltag ein Freilos.
  factory Liga.mitSpielplan({
    required String name,
    required List<Team> teams,
    List<Tisch> tische = const [],
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

        hinBeg.add(
          Begegnung(
            id: 'b${begId++}',
            heimTeam: heim,
            gastTeam: gast,
            istHinrunde: true,
          ),
        );
        rueckBeg.add(
          Begegnung(
            id: 'b${begId++}',
            heimTeam: gast,
            gastTeam: heim,
            istHinrunde: false,
          ),
        );
      }

      hinrunde.add(
        Spieltag(
          nummer: round + 1,
          istHinrunde: true,
          freilos: freilos,
          begegnungen: hinBeg,
        ),
      );
      rueckrunde.add(
        Spieltag(
          nummer: rounds + round + 1,
          istHinrunde: false,
          freilos: freilos,
          begegnungen: rueckBeg,
        ),
      );

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
      tische: tische,
    );
  }

  // ── Aufstellung ─────────────────────────────────────────────────

  /// IDs aller Spieler, die in mindestens einem Spiel aufgestellt sind.
  Set<String> get aufgestellteSpielerIds {
    final ids = <String>{};
    for (final beg in begegnungen) {
      for (final spiel in beg.spiele.whereType<Spiel>()) {
        switch (spiel) {
          case Einzel(
            :final heimSpieler,
            :final gastSpieler,
          ):
            if (heimSpieler != null) {
              ids.add(heimSpieler.id);
            }
            if (gastSpieler != null) {
              ids.add(gastSpieler.id);
            }
          case Doppel(
            :final heimSpieler,
            :final gastSpieler,
          ):
            ids.addAll(
              heimSpieler.map((s) {
                return s.id;
              }),
            );
            ids.addAll(
              gastSpieler.map((s) {
                return s.id;
              }),
            );
        }
      }
    }
    return ids;
  }

  // ── Mutationen ───────────────────────────────────────────────────

  /// Ersetzt in allen Spieltagen die Team-Referenz durch [neues].
  (List<Spieltag>, List<Spieltag>) _tageMitTeam(Team neues) {
    Spieltag aktualisieren(Spieltag st) => Spieltag(
      nummer: st.nummer,
      istHinrunde: st.istHinrunde,
      freilos: st.freilos?.id == neues.id ? neues : st.freilos,
      begegnungen: st.begegnungen.map(
        (b) {
          return Begegnung(
            id: b.id,
            heimTeam: b.heimTeam.id == neues.id ? neues : b.heimTeam,
            gastTeam: b.gastTeam.id == neues.id ? neues : b.gastTeam,
            istHinrunde: b.istHinrunde,
            spiele: b.spiele,
          );
        },
      ).toList(),
    );
    return (
      hinrunde.map(aktualisieren).toList(),
      rueckrunde.map(aktualisieren).toList(),
    );
  }

  bool get hatErgebnisse => begegnungen.any(
    (b) {
      return b.spiele.whereType<Spiel>().any((s) {
        return s.saetze.isNotEmpty;
      });
    },
  );

  Liga mitTeamUmbenennt(
    String teamId,
    String neuerName,
  ) {
    final altes = teams.firstWhere((t) {
      return t.id == teamId;
    });
    final neues = Team(id: altes.id, name: neuerName, spieler: altes.spieler);

    Spieltag aktualisiereTag(Spieltag st) => Spieltag(
      nummer: st.nummer,
      istHinrunde: st.istHinrunde,
      freilos: st.freilos?.id == teamId ? neues : st.freilos,
      begegnungen: st.begegnungen.map(
        (b) {
          return Begegnung(
            id: b.id,
            heimTeam: b.heimTeam.id == teamId ? neues : b.heimTeam,
            gastTeam: b.gastTeam.id == teamId ? neues : b.gastTeam,
            istHinrunde: b.istHinrunde,
            spiele: b.spiele,
          );
        },
      ).toList(),
    );

    return Liga(
      name: name,
      teams: teams.map((t) {
        return t.id == teamId ? neues : t;
      }).toList(),
      hinrunde: hinrunde.map(aktualisiereTag).toList(),
      rueckrunde: rueckrunde.map(aktualisiereTag).toList(),
      tische: tische,
    );
  }

  Liga mitTeamHinzugefuegt(Team neuesTeam) => Liga.mitSpielplan(
    name: name,
    teams: [...teams, neuesTeam],
    tische: tische,
  );

  Liga mitSpielerUmbenennt(
    String teamId,
    Spieler aktualisiert,
  ) {
    Spiel spielerErsetzen(Spiel spiel) => switch (spiel) {
      Einzel(
        :final heimSpieler,
        :final gastSpieler,
        :final satz,
      ) =>
        Einzel(
          heimSpieler: heimSpieler?.id == aktualisiert.id
              ? aktualisiert
              : heimSpieler,
          gastSpieler: gastSpieler?.id == aktualisiert.id
              ? aktualisiert
              : gastSpieler,
          satz: satz,
        ),
      Doppel(
        :final heimSpieler,
        :final gastSpieler,
        :final saetze,
      ) =>
        Doppel(
          heimSpieler: heimSpieler.map((s) {
            return s.id == aktualisiert.id ? aktualisiert : s;
          }).toList(),
          gastSpieler: gastSpieler.map((s) {
            return s.id == aktualisiert.id ? aktualisiert : s;
          }).toList(),
          saetze: saetze,
        ),
    };

    final neuesTeam = Team(
      id: teamId,
      name: teams.firstWhere((t) {
        return t.id == teamId;
      }).name,
      spieler: teams
          .firstWhere((t) {
            return t.id == teamId;
          })
          .spieler
          .map((s) {
            return s.id == aktualisiert.id ? aktualisiert : s;
          })
          .toList(),
    );
    final (hinr, rueckr) = _tageMitTeam(neuesTeam);

    Spieltag tagMitSpiele(Spieltag alt, Spieltag neu) => Spieltag(
      nummer: neu.nummer,
      istHinrunde: neu.istHinrunde,
      freilos: neu.freilos,
      begegnungen: neu.begegnungen.indexed.map(
        ((int, Begegnung) e) {
          return Begegnung(
            id: e.$2.id,
            heimTeam: e.$2.heimTeam,
            gastTeam: e.$2.gastTeam,
            istHinrunde: e.$2.istHinrunde,
            spiele: alt.begegnungen[e.$1].spiele.map((s) {
              return s != null ? spielerErsetzen(s) : null;
            }).toList(),
          );
        },
      ).toList(),
    );

    return Liga(
      name: name,
      teams: teams.map((t) {
        return t.id == teamId ? neuesTeam : t;
      }).toList(),
      hinrunde: List.generate(
        hinr.length,
        (i) {
          return tagMitSpiele(hinrunde[i], hinr[i]);
        },
      ),
      rueckrunde: List.generate(
        rueckr.length,
        (i) {
          return tagMitSpiele(rueckrunde[i], rueckr[i]);
        },
      ),
      tische: tische,
    );
  }

  Liga mitSpielerHinzugefuegt(
    String teamId,
    Spieler neuerSpieler,
  ) {
    final altes = teams.firstWhere((t) {
      return t.id == teamId;
    });
    final neues = Team(
      id: altes.id,
      name: altes.name,
      spieler: [...altes.spieler, neuerSpieler],
    );
    final (hinr, rueckr) = _tageMitTeam(neues);
    return Liga(
      name: name,
      teams: teams.map((t) {
        return t.id == teamId ? neues : t;
      }).toList(),
      hinrunde: hinr,
      rueckrunde: rueckr,
      tische: tische,
    );
  }

  Liga mitSpielerEntfernt(
    String teamId,
    String spielerId,
  ) {
    final altes = teams.firstWhere((t) {
      return t.id == teamId;
    });
    final neues = Team(
      id: altes.id,
      name: altes.name,
      spieler: altes.spieler.where((s) {
        return s.id != spielerId;
      }).toList(),
    );
    final (hinr, rueckr) = _tageMitTeam(neues);
    return Liga(
      name: name,
      teams: teams.map((t) {
        return t.id == teamId ? neues : t;
      }).toList(),
      hinrunde: hinr,
      rueckrunde: rueckr,
      tische: tische,
    );
  }

  Liga mitTeamEntfernt(String teamId) {
    return Liga.mitSpielplan(
      name: name,
      teams: teams.where((t) {
        return t.id != teamId;
      }).toList(),
      tische: tische,
    );
  }

  // ── Tisch-Mutationen ─────────────────────────────────────────────

  Liga mitTischHinzugefuegt(Tisch tisch) => Liga(
    name: name,
    teams: teams,
    hinrunde: hinrunde,
    rueckrunde: rueckrunde,
    tische: [...tische, tisch],
  );

  Liga mitTischEntfernt(String tischId) => Liga(
    name: name,
    teams: teams,
    hinrunde: hinrunde,
    rueckrunde: rueckrunde,
    tische: tische.where((t) {
      return t.id != tischId;
    }).toList(),
  );

  Liga mitTischUmbenennt(
    String tischId,
    String neuerName,
  ) => Liga(
    name: name,
    teams: teams,
    hinrunde: hinrunde,
    rueckrunde: rueckrunde,
    tische: tische.map((t) {
      return t.id == tischId ? Tisch(id: t.id, name: neuerName) : t;
    }).toList(),
  );

  /// Gibt eine neue [Liga] zurück, bei der [begegnung] (per ID) ersetzt ist.
  Liga mitBegegnung(Begegnung begegnung) {
    return Liga(
      name: name,
      teams: teams,
      hinrunde: hinrunde.map((st) {
        return st.mitBegegnung(begegnung);
      }).toList(),
      rueckrunde: rueckrunde.map((st) {
        return st.mitBegegnung(begegnung);
      }).toList(),
      tische: tische,
    );
  }

  // ── Statistiken pro Team ─────────────────────────────────────────

  Iterable<Begegnung> abgeschlossen(Team team) => begegnungen.where(
    (b) {
      return b.istAbgeschlossen && (b.heimTeam == team || b.gastTeam == team);
    },
  );

  int ligapunkteVon(Team team) {
    return abgeschlossen(team).fold(0, (sum, b) {
      if (b.heimTeam == team) {
        return sum + b.ligapunkteHeim;
      }
      return sum + b.ligapunkteGast;
    });
  }

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

  int torDifferenzVon(Team team) {
    return toreVon(team) - gegenToreVon(team);
  }

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

  int _direkterVergleich(
    Team a,
    Team b,
  ) {
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

  /// Teams sortiert nach: Ligapunkte, Punktedifferenz (+/-),
  /// Tordifferenz, Direkter Vergleich.
  List<Team> get tabelle {
    final sorted = List<Team>.from(teams)
      ..sort((a, b) {
        final lp = ligapunkteVon(b).compareTo(ligapunkteVon(a));
        if (lp != 0) {
          return lp;
        }
        final pv = punkteDifferenzVon(b).compareTo(punkteDifferenzVon(a));
        if (pv != 0) {
          return pv;
        }
        final tv = torDifferenzVon(b).compareTo(torDifferenzVon(a));
        if (tv != 0) {
          return tv;
        }
        return _direkterVergleich(b, a);
      });
    return sorted;
  }

  // ── Spieler-Statistiken ──────────────────────────────────────────

  /// Top 10 Spieler sortiert nach: Ligapunkte-Quote, dann Tordifferenz.
  /// Nur Spieler mit mindestens einem gespielten Satz.
  List<SpielerStats> spielerTopListe() {
    final Map<String, SpielerStats> map = {};

    void add(
      Spieler spieler,
      Team team,
      int punkteGeholt,
      int toreGeholt,
      int toreKassiert,
    ) {
      final neu = SpielerStats(
        spieler: spieler,
        team: team,
        punkteGeholt: punkteGeholt,
        punkteMoeglich: 2,
        toreGeholt: toreGeholt,
        toreKassiert: toreKassiert,
      );
      map[spieler.id] = map.containsKey(spieler.id)
          ? map[spieler.id]! + neu
          : neu;
    }

    for (final beg in begegnungen) {
      for (final slot in SpielSlot.values) {
        switch (beg.spielAt(slot)) {
          case Einzel(
                :final heimSpieler,
                :final gastSpieler,
                satz: final Satz satz,
              )
              when satz.istAbgeschlossen:
            if (heimSpieler != null) {
              add(
                heimSpieler,
                beg.heimTeam,
                satz.punkteHeim,
                satz.heimTore,
                satz.gastTore,
              );
            }
            if (gastSpieler != null) {
              add(
                gastSpieler,
                beg.gastTeam,
                satz.punkteGast,
                satz.gastTore,
                satz.heimTore,
              );
            }
          case Doppel(
            :final heimSpieler,
            :final gastSpieler,
            :final saetze,
          ):
            for (final satz in saetze.where(
              (s) {
                return s.istAbgeschlossen;
              },
            )) {
              for (final sp in heimSpieler) {
                add(
                  sp,
                  beg.heimTeam,
                  satz.punkteHeim,
                  satz.heimTore,
                  satz.gastTore,
                );
              }
              for (final sp in gastSpieler) {
                add(
                  sp,
                  beg.gastTeam,
                  satz.punkteGast,
                  satz.gastTore,
                  satz.heimTore,
                );
              }
            }
          default:
            break;
        }
      }
    }

    return (map.values
          .where((s) { return s.punkteMoeglich >= 6; })
          .toList()
        ..sort((a, b) {
          final q = b.bayesianQuote.compareTo(a.bayesianQuote);
          if (q != 0) {
            return q;
          }
          return b.torDifferenz.compareTo(a.torDifferenz);
        }))
        .take(10)
        .toList();
  }

  // ── JSON ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'name': name,
    'teams': teams.map((t) {
      return t.toJson();
    }).toList(),
    'hinrunde': hinrunde.map((st) {
      return st.toJson();
    }).toList(),
    'rueckrunde': rueckrunde.map((st) {
      return st.toJson();
    }).toList(),
    'tische': tische.map((t) {
      return t.toJson();
    }).toList(),
  };

  factory Liga.fromJson(
    Map<String, dynamic> json,
  ) {
    final teams = (json['teams'] as List<dynamic>).map((t) {
      return Team.fromJson(t as Map<String, dynamic>);
    }).toList();
    final teamsById = {for (final t in teams) t.id: t};
    final spielerById = {
      for (final t in teams)
        for (final s in t.spieler) s.id: s,
    };

    final tische = ((json['tische'] as List<dynamic>?) ?? []).map((t) {
      return Tisch.fromJson(t as Map<String, dynamic>);
    }).toList();
    final tischeById = {for (final t in tische) t.id: t};

    return Liga(
      name: json['name'] as String,
      teams: teams,
      hinrunde: (json['hinrunde'] as List<dynamic>).map(
        (st) {
          return Spieltag.fromJson(
            st as Map<String, dynamic>,
            teamsById,
            tischeById,
            spielerById,
          );
        },
      ).toList(),
      rueckrunde: (json['rueckrunde'] as List<dynamic>).map(
        (st) {
          return Spieltag.fromJson(
            st as Map<String, dynamic>,
            teamsById,
            tischeById,
            spielerById,
          );
        },
      ).toList(),
      tische: tische,
    );
  }
}
