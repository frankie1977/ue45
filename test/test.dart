// Team A – Rote Teufel
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';

final _a1 = Spieler(id: 'a1', vorname: 'Anna', nachname: 'Meier');
final _a2 = Spieler(id: 'a2', vorname: 'Ben', nachname: 'Schulz');
final _a3 = Spieler(id: 'a3', vorname: 'Clara', nachname: 'Wolf');
final _a4 = Spieler(id: 'a4', vorname: 'David', nachname: 'Koch');
final _a5 = Spieler(id: 'a5', vorname: 'Eva', nachname: 'Braun');

// Team B – Blaue Blitze
final _b1 = Spieler(id: 'b1', vorname: 'Felix', nachname: 'Maier');
final _b2 = Spieler(id: 'b2', vorname: 'Greta', nachname: 'Lang');
final _b3 = Spieler(id: 'b3', vorname: 'Hans', nachname: 'Bauer');
final _b4 = Spieler(id: 'b4', vorname: 'Ida', nachname: 'Neumann');
final _b5 = Spieler(id: 'b5', vorname: 'Jan', nachname: 'Fischer');

// Team C – Grüne Wölfe
final _c1 = Spieler(id: 'c1', vorname: 'Kai', nachname: 'Richter');
final _c2 = Spieler(id: 'c2', vorname: 'Lisa', nachname: 'Klein');
final _c3 = Spieler(id: 'c3', vorname: 'Max', nachname: 'Weiß');
final _c4 = Spieler(id: 'c4', vorname: 'Nina', nachname: 'Schwarz');
final _c5 = Spieler(id: 'c5', vorname: 'Otto', nachname: 'Müller');

final teamA = Team(
  id: 'tA',
  name: 'Rote Teufel',
  spieler: [_a1, _a2, _a3, _a4, _a5],
);
final teamB = Team(
  id: 'tB',
  name: 'Blaue Blitze',
  spieler: [_b1, _b2, _b3, _b4, _b5],
);
final teamC = Team(
  id: 'tC',
  name: 'Grüne Wölfe',
  spieler: [_c1, _c2, _c3, _c4, _c5],
);

void main() {
  Liga liga = Liga.mitSpielplan(
    name: 'Testliga',
    teams: [teamA, teamB, teamC],
  );

  // final Begegnung b = Begegnung(id: '1', heimTeam: teamA, gastTeam: teamB, istHinrunde: true);

  // print(liga.begegnungen);

  Begegnung alte = liga.begegnungen.first;

  liga = liga.mitBegegnung(
    alte
        .mitSpiel(
          SpielSlot.d1,
          Doppel(
            heimSpieler: [_a1, _a2],
            gastSpieler: [_b4, _b2],
            saetze: [
              Satz(
                heimTore: 7,
                gastTore: 0,
              ),
              Satz(
                heimTore: 7,
                gastTore: 0,
              ),
            ],
          ),
        )
        .mitSpiel(
          SpielSlot.e1,
          Einzel(
            heimSpieler: _a1,
            gastSpieler: _b4,
            satz: Satz(
              heimTore: 7,
              gastTore: 0,
            ),
          ),
        )
        .mitSpiel(
          SpielSlot.d2,
          Doppel(
            heimSpieler: [_a1, _a2],
            gastSpieler: [_b4, _b2],
            saetze: [
              Satz(
                heimTore: 7,
                gastTore: 0,
              ),
              Satz(
                heimTore: 7,
                gastTore: 0,
              ),
            ],
          ),
        )
        .mitSpiel(
          SpielSlot.e2,
          Einzel(
            heimSpieler: _a1,
            gastSpieler: _b4,
            satz: Satz(
              heimTore: 7,
              gastTore: 0,
            ),
          ),
        )
        .mitSpiel(
          SpielSlot.d3,
          Doppel(
            heimSpieler: [_a1, _a2],
            gastSpieler: [_b4, _b2],
            saetze: [
              Satz(
                heimTore: 7,
                gastTore: 0,
              ),
              Satz(
                heimTore: 7,
                gastTore: 0,
              ),
            ],
          ),
        )
        .mitSpiel(
          SpielSlot.e3,
          Einzel(
            heimSpieler: _a1,
            gastSpieler: _b4,
            satz: Satz(
              heimTore: 7,
              gastTore: 0,
            ),
          ),
        )
        .mitSpiel(
          SpielSlot.d4,
          Doppel(
            heimSpieler: [_a1, _a2],
            gastSpieler: [_b4, _b2],
            saetze: [
              Satz(
                heimTore: 6,
                gastTore: 6,
              ),
              Satz(
                heimTore: 7,
                gastTore: 0,
              ),
            ],
          ),
        ),
  );

  // for (Begegnung b in liga2.begegnungen) {
  //   print('$b - abgeschlossen: ${b.istAbgeschlossen}');
  //   for (Spiel? s in b.spiele) {
  //     print('$s - abgeschlossen: ${s?.istAbgeschlossen}');
  //     if (s != null) {
  //       for (Satz a in s!.saetze) {
  //         print('$a - abgeschlossen: ${a?.istAbgeschlossen}');
  //       }
  //     }
  //   }
  //   break;
  // }

  // print(liga2.begegnungen.first.spiele);
  // print(liga2.begegnungen.first);
  // print(liga2.begegnungen.first.spiele[0]!.toJson());

  int rank = 1;
  for (Team team in liga.tabelle) {
    // print(liga.abgeschlossen(team));
    print(
      '$rank. ${team.name} >> P:${liga.ligapunkteVon(team)} --- '
      ' S:${liga.siegeVon(team)} U:${liga.unentschiedenVon(team)} N:${liga.niederlagenVon(team)} '
      ' --- X:${liga.punkteDifferenzVon(team)} --- '
      'T:${liga.torDifferenzVon(team)} T+:${liga.toreVon(team)} T-:${liga.gegenToreVon(team)}',
    );
    rank++;
  }
}
