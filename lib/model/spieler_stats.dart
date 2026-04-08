import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';

class SpielerStats {
  const SpielerStats({
    required this.spieler,
    required this.team,
    required this.punkteGeholt,
    required this.punkteMoeglich,
    required this.toreGeholt,
    required this.toreKassiert,
  });

  final Spieler spieler;
  final Team team;
  final int punkteGeholt;
  final int punkteMoeglich;
  final int toreGeholt;
  final int toreKassiert;

  double get quote =>
      punkteMoeglich == 0 ? 0 : punkteGeholt / punkteMoeglich;

  int get torDifferenz => toreGeholt - toreKassiert;

  SpielerStats operator +(SpielerStats other) => SpielerStats(
    spieler: spieler,
    team: team,
    punkteGeholt: punkteGeholt + other.punkteGeholt,
    punkteMoeglich: punkteMoeglich + other.punkteMoeglich,
    toreGeholt: toreGeholt + other.toreGeholt,
    toreKassiert: toreKassiert + other.toreKassiert,
  );
}
