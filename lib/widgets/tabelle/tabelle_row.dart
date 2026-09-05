import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/team.dart';
import 'package:ue45x/widgets/tabelle/tabelle_spalten.dart';

class TabelleRow extends StatelessWidget {
  const TabelleRow({
    required this.rang,
    required this.team,
    required this.liga,
    this.breiteNamen = false,
    super.key,
  });

  final int rang;
  final Team team;
  final Liga liga;

  /// Teamname belegt die halbe Breite, die Statistik-Spalten teilen sich
  /// den Rest (Anzeigemodus).
  final bool breiteNamen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gespielt = liga.abgeschlossen(team).length;
    final punkte = liga.ligapunkteVon(team);
    final siege = liga.siegeVon(team);
    final unentschieden = liga.unentschiedenVon(team);
    final niederlagen = liga.niederlagenVon(team);
    final diff = liga.punkteDifferenzVon(team);
    final tore = liga.toreVon(team);
    final gegenTore = liga.gegenToreVon(team);
    final torDiff = liga.torDifferenzVon(team);

    final diffText = diff > 0 ? '+$diff' : '$diff';
    final diffColor = diff > 0
        ? theme.colorScheme.primary
        : diff < 0
        ? theme.colorScheme.error
        : theme.colorScheme.outline;
    final torDiffColor = torDiff > 0
        ? theme.colorScheme.primary
        : torDiff < 0
        ? theme.colorScheme.error
        : theme.colorScheme.outline;

    Widget spalte(
      String text,
      int flex, {
      TextStyle? style,
    }) {
      return tabelleSpalte(
        flex: flex,
        flexibel: breiteNamen,
        kind: Text(
          text,
          textAlign: .center,
          style: style ?? theme.textTheme.bodySmall,
        ),
      );
    }

    return Padding(
      padding: const .symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: tabelleRangBreite,
            child: Text(
              '$rang',
              textAlign: .right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(
            width: tabelleRangAbstand,
          ),
          Expanded(
            flex: breiteNamen ? tabelleFlexTeam : 1,
            child: Text(
              team.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: .bold,
              ),
            ),
          ),
          spalte(
            '$gespielt',
            tabelleFlexSpiele,
          ),
          spalte(
            '$tore:$gegenTore',
            tabelleFlexTore,
          ),
          spalte(
            torDiff > 0 ? '+$torDiff' : '$torDiff',
            tabelleFlexTorDifferenz,
            style: theme.textTheme.bodySmall?.copyWith(
              color: torDiffColor,
            ),
          ),
          spalte(
            '$siege',
            tabelleFlexSiege,
          ),
          spalte(
            '$unentschieden',
            tabelleFlexUnentschieden,
          ),
          spalte(
            '$niederlagen',
            tabelleFlexNiederlagen,
          ),
          spalte(
            diffText,
            tabelleFlexPunkteDifferenz,
            style: theme.textTheme.bodySmall?.copyWith(
              color: diffColor,
            ),
          ),
          spalte(
            '$punkte',
            tabelleFlexPunkte,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: .bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
