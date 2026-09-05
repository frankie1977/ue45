import 'package:flutter/material.dart';

/// Gemeinsame Spaltenaufteilung von TabelleHeader und TabelleRow.
///
/// Der Rang steht immer in fester Breite. Die uebrigen Spalten sind entweder
/// fix (Bearbeiten-Tab) oder flexibel (Anzeigemodus): flexibel entspricht
/// [tabelleFlexTeam] der Summe aller Statistik-Spalten, der Teamname belegt
/// damit die Haelfte der Breite und die rechten Spalten wachsen entsprechend.
const double tabelleRangBreite = 28;
const double tabelleRangAbstand = 10;

const int tabelleFlexSpiele = 32;
const int tabelleFlexTore = 78;
const int tabelleFlexTorDifferenz = 58;
const int tabelleFlexSiege = 32;
const int tabelleFlexUnentschieden = 32;
const int tabelleFlexNiederlagen = 32;
const int tabelleFlexPunkteDifferenz = 44;
const int tabelleFlexPunkte = 36;

const int tabelleFlexTeam =
    tabelleFlexSpiele +
    tabelleFlexTore +
    tabelleFlexTorDifferenz +
    tabelleFlexSiege +
    tabelleFlexUnentschieden +
    tabelleFlexNiederlagen +
    tabelleFlexPunkteDifferenz +
    tabelleFlexPunkte;

/// Legt [kind] in einer Spalte ab: mit [flexibel] als Anteil von [flex],
/// sonst in der festen Breite [flex].
Widget tabelleSpalte({
  required Widget kind,
  required int flex,
  required bool flexibel,
}) {
  if (flexibel) {
    return Expanded(
      flex: flex,
      child: kind,
    );
  }
  return SizedBox(
    width: flex.toDouble(),
    child: kind,
  );
}
