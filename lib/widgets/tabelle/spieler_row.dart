import 'package:flutter/material.dart';
import 'package:ue45x/model/spieler_stats.dart';

class SpielerRow extends StatelessWidget {
  const SpielerRow({
    required this.rang,
    required this.stats,
    super.key,
  });

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8,),
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
          SizedBox(
            width: 10,
          ),
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
            width: 36,
            child: Text(
              '${stats.punkteMoeglich ~/ 2}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          SizedBox(
            width: 112,
            child: Text(
              '${stats.punkteGeholt} ($pct)',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              torDiffText,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: torDiffColor,),
            ),
          ),
        ],
      ),
    );
  }
}
