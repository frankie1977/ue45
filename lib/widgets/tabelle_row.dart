import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/team.dart';

class TabelleRow extends StatelessWidget {
  const TabelleRow({
    required this.rang,
    required this.team,
    required this.liga,
    super.key,
  });

  final int rang;
  final Team team;
  final Liga liga;

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

    final diffText = diff > 0 ? '+$diff' : '$diff';
    final diffColor = diff > 0
        ? theme.colorScheme.primary
        : diff < 0
            ? theme.colorScheme.error
            : theme.colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rang',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
          Expanded(
            child: Text(
              team.name,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$gespielt',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$siege',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$unentschieden',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$niederlagen',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              diffText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: diffColor),
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              '$tore:$gegenTore',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$punkte',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
