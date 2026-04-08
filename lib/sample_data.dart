import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';

Liga buildSampleLiga() {
  // Team A – Rote Teufel
  final a1 = Spieler(id: 'a1', vorname: 'Anna', nachname: 'Meier');
  final a2 = Spieler(id: 'a2', vorname: 'Ben', nachname: 'Schulz');
  final a3 = Spieler(id: 'a3', vorname: 'Clara', nachname: 'Wolf');
  final a4 = Spieler(id: 'a4', vorname: 'David', nachname: 'Koch');
  final a5 = Spieler(id: 'a5', vorname: 'Eva', nachname: 'Braun');

  // Team B – Blaue Blitze
  final b1 = Spieler(id: 'b1', vorname: 'Felix', nachname: 'Maier');
  final b2 = Spieler(id: 'b2', vorname: 'Greta', nachname: 'Lang');
  final b3 = Spieler(id: 'b3', vorname: 'Hans', nachname: 'Bauer');
  final b4 = Spieler(id: 'b4', vorname: 'Ida', nachname: 'Neumann');
  final b5 = Spieler(id: 'b5', vorname: 'Jan', nachname: 'Fischer');

  // Team C – Grüne Wölfe
  final c1 = Spieler(id: 'c1', vorname: 'Kai', nachname: 'Richter');
  final c2 = Spieler(id: 'c2', vorname: 'Lisa', nachname: 'Klein');
  final c3 = Spieler(id: 'c3', vorname: 'Max', nachname: 'Weiß');
  final c4 = Spieler(id: 'c4', vorname: 'Nina', nachname: 'Schwarz');
  final c5 = Spieler(id: 'c5', vorname: 'Otto', nachname: 'Müller');

  // Team D – Gelbe Adler
  final d1 = Spieler(id: 'd1', vorname: 'Paul', nachname: 'Hoffmann');
  final d2 = Spieler(id: 'd2', vorname: 'Petra', nachname: 'Wagner');
  final d3 = Spieler(id: 'd3', vorname: 'Ralf', nachname: 'Zimmer');
  final d4 = Spieler(id: 'd4', vorname: 'Sara', nachname: 'Frank');
  final d5 = Spieler(id: 'd5', vorname: 'Tim', nachname: 'Gruber');

  // Team E – Schwarze Panther
  final e1 = Spieler(id: 'e1', vorname: 'Ute', nachname: 'Keller');
  final e2 = Spieler(id: 'e2', vorname: 'Volker', nachname: 'Stein');
  final e3 = Spieler(id: 'e3', vorname: 'Wendy', nachname: 'Brandt');
  final e4 = Spieler(id: 'e4', vorname: 'Xaver', nachname: 'Huber');
  final e5 = Spieler(id: 'e5', vorname: 'Yvonne', nachname: 'Sommer');

  // Team F – Silberne Falken
  final f1 = Spieler(id: 'f1', vorname: 'Zara', nachname: 'Böhm');
  final f2 = Spieler(id: 'f2', vorname: 'Adam', nachname: 'Krause');
  final f3 = Spieler(id: 'f3', vorname: 'Bianca', nachname: 'Lorenz');
  final f4 = Spieler(id: 'f4', vorname: 'Chris', nachname: 'Vogt');
  final f5 = Spieler(id: 'f5', vorname: 'Diana', nachname: 'Herz');

  // Team G – Goldene Löwen
  final g1 = Spieler(id: 'g1', vorname: 'Emil', nachname: 'Haas');
  final g2 = Spieler(id: 'g2', vorname: 'Fiona', nachname: 'Berg');
  final g3 = Spieler(id: 'g3', vorname: 'Georg', nachname: 'Sauer');
  final g4 = Spieler(id: 'g4', vorname: 'Hannah', nachname: 'Roth');
  final g5 = Spieler(id: 'g5', vorname: 'Ivan', nachname: 'Stern');

  final teamA = Team(
    id: 'tA',
    name: 'Rote Teufel',
    spieler: [a1, a2, a3, a4, a5],
  );
  final teamB = Team(
    id: 'tB',
    name: 'Blaue Blitze',
    spieler: [b1, b2, b3, b4, b5],
  );
  final teamC = Team(
    id: 'tC',
    name: 'Grüne Wölfe',
    spieler: [c1, c2, c3, c4, c5],
  );
  final teamD = Team(
    id: 'tD',
    name: 'Gelbe Adler',
    spieler: [d1, d2, d3, d4, d5],
  );
  final teamE = Team(
    id: 'tE',
    name: 'Schwarze Panther',
    spieler: [e1, e2, e3, e4, e5],
  );
  final teamF = Team(
    id: 'tF',
    name: 'Silberne Falken',
    spieler: [f1, f2, f3, f4, f5],
  );
  final teamG = Team(
    id: 'tG',
    name: 'Goldene Löwen',
    spieler: [g1, g2, g3, g4, g5],
  );

  Liga liga = Liga.mitSpielplan(
    name: 'Testliga',
    teams: [teamA, teamB, teamC, teamD, teamE, teamF, teamG],
  );

  final Begegnung alte = liga.begegnungen.first;

  liga = liga.mitBegegnung(
    alte
        .mitSpiel(
          SpielSlot.d1,
          Doppel(
            heimSpieler: [a1, a2],
            gastSpieler: [b4, b2],
            saetze: [
              Satz(
                heimTore: 6,
                gastTore: 6,
              ),
              Satz(
                heimTore: 7,
                gastTore: 2,
              ),
            ],
          ),
        )
        .mitSpiel(
          SpielSlot.e1,
          Einzel(
            heimSpieler: a1,
            gastSpieler: b4,
            satz: Satz(
              heimTore: 7,
              gastTore: 3,
            ),
          ),
        )
        .mitSpiel(
          SpielSlot.d2,
          Doppel(
            heimSpieler: [a1, a2],
            gastSpieler: [b4, b2],
            saetze: [
              Satz(
                heimTore: 7,
                gastTore: 3,
              ),
              Satz(
                heimTore: 7,
                gastTore: 5,
              ),
            ],
          ),
        )
        .mitSpiel(
          SpielSlot.e2,
          Einzel(
            heimSpieler: a1,
            gastSpieler: b4,
            satz: Satz(
              heimTore: 7,
              gastTore: 5,
            ),
          ),
        )
        .mitSpiel(
          SpielSlot.d3,
          Doppel(
            heimSpieler: [a1, a2],
            gastSpieler: [b4, b2],
            saetze: [
              Satz(
                heimTore: 7,
                gastTore: 2,
              ),
              Satz(
                heimTore: 4,
                gastTore: 7,
              ),
            ],
          ),
        )
        .mitSpiel(
          SpielSlot.e3,
          Einzel(
            heimSpieler: a1,
            gastSpieler: b4,
            satz: Satz(
              heimTore: 3,
              gastTore: 7,
            ),
          ),
        )
        .mitSpiel(
          SpielSlot.d4,
          Doppel(
            heimSpieler: [a1, a2],
            gastSpieler: [b4, b2],
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
  final Begegnung zweite = liga.begegnungen[1];
  liga = liga.mitBegegnung(
    zweite
        .mitSpiel(
          SpielSlot.d1,
          Doppel(
            heimSpieler: [b1, b2],
            gastSpieler: [e1, e2],
          ),
        )
        .mitSpiel(
          SpielSlot.e1,
          Einzel(
            heimSpieler: b3,
            gastSpieler: e3,
          ),
        )
        .mitSpiel(
          SpielSlot.d2,
          Doppel(
            heimSpieler: [b3, b4],
            gastSpieler: [e3, e4],
          ),
        )
        .mitSpiel(
          SpielSlot.e2,
          Einzel(
            heimSpieler: b4,
            gastSpieler: e4,
          ),
        )
        .mitSpiel(
          SpielSlot.d3,
          Doppel(
            heimSpieler: [b1, b3],
            gastSpieler: [e1, e3],
          ),
        )
        .mitSpiel(
          SpielSlot.e3,
          Einzel(
            heimSpieler: b5,
            gastSpieler: e5,
          ),
        )
        .mitSpiel(
          SpielSlot.d4,
          Doppel(
            heimSpieler: [b2, b5],
            gastSpieler: [e2, e5],
          ),
        ),
  );
  return liga;
}
