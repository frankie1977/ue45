
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spiel.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';
import 'package:ue45x/sample_data.dart';



void main() {
  Liga liga = buildSampleLiga();

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
