import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spieler_stats.dart';
import 'package:ue45x/widgets/tabelle/spieler_row.dart';

class SpielerTopListe extends StatelessWidget {
  const SpielerTopListe({required this.liga, super.key});

  final Liga liga;

  @override
  Widget build(BuildContext context) {
    final liste = liga.spielerTopListe();
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
                  SizedBox(
                    width: 28,
                    child: Text(
                      '#',
                      style: labelStyle,
                      textAlign: .right,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(child: Text('Spieler:in', style: labelStyle)),
                  SizedBox(
                    width: 36,
                    child: Text(
                      'S',
                      style: labelStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 112,
                    child: Text(
                      'Pkt',
                      style: labelStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      'Tore',
                      style: labelStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...liste.indexed.map(
              ((int, SpielerStats) e) {
                return SpielerRow(
                  rang: e.$1 + 1,
                  stats: e.$2,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
