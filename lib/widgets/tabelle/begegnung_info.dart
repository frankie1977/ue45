import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/spiel.dart';

class BegegnungInfo extends StatelessWidget {
  const BegegnungInfo({
    required this.beg,
    required this.slot,
    required this.heimLinks,
    required this.spielerTexte,
    this.viewModus = false,
    super.key,
  });

  final Begegnung beg;
  final SpielSlot? slot;
  final bool heimLinks;
  final (String, String) Function(Spiel?, bool) spielerTexte;
  final bool viewModus;

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final spiel = slot != null ? beg.spielAt(slot!) : null;
    final (linksText, rechtsText) = spielerTexte(spiel, heimLinks);
    final linksTeam = heimLinks ? beg.heimTeam.name : beg.gastTeam.name;
    final rechtsTeam = heimLinks ? beg.gastTeam.name : beg.heimTeam.name;
    final linksPunkte = heimLinks ? beg.satzpunkteHeim : beg.satzpunkteGast;
    final rechtsPunkte = heimLinks ? beg.satzpunkteGast : beg.satzpunkteHeim;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                linksTeam,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: viewModus ? 16.0 : 0.0,
              ),
              child: SizedBox(
                width: 52,
                child: Text(
                  '$linksPunkte:$rechtsPunkte',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                rechtsTeam,
                textAlign: TextAlign.left,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 2,
        ),
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: Text(
                linksText,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: viewModus ? 16.0 : 0.0,
              ),
              child: SizedBox(
                width: 52,
                child: Text(
                  slot?.label ?? '',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                rechtsText,
                textAlign: TextAlign.left,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
