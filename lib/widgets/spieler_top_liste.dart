import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spieler_stats.dart';

class SpielerTopListe extends StatelessWidget {
  const SpielerTopListe({required this.liga, super.key});

  final Liga liga;

  @override
  Widget build(BuildContext context) {
    final liste = liga.spielerTopListe;
    if (liste.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.outline,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 28, child: Text('#', style: labelStyle, textAlign: .right,)),
                  SizedBox(width: 10,),
                  Expanded(child: Text('Spieler:in', style: labelStyle)),
                  SizedBox(
                    width: 152,
                    child: Text(
                      'Pkt',
                      style: labelStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '+/−',
                      style: labelStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...liste.indexed.map(
              ((int, SpielerStats) e) => _SpielerRow(
                rang: e.$1 + 1,
                stats: e.$2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpielerRow extends StatelessWidget {
  const _SpielerRow({required this.rang, required this.stats});

  final int rang;
  final SpielerStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final torDiff = stats.torDifferenz;
    final torDiffText = torDiff > 0 ? '+$torDiff' : '$torDiff';
    final torDiffColor = torDiff > 0
        ? theme.colorScheme.primary
        : torDiff < 0
            ? theme.colorScheme.error
            : theme.colorScheme.outline;

    final pct = stats.punkteMoeglich == 0
        ? '–'
        : '${(stats.quote * 100).round()}%';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rang',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.spieler.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stats.team.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 152,
            child: Text(
              '${stats.punkteGeholt}/${stats.punkteMoeglich} ($pct)',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              torDiffText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: torDiffColor),
            ),
          ),
        ],
      ),
    );
  }
}
