import 'package:flutter/material.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';

class SpielerPickerDialog extends StatelessWidget {
  const SpielerPickerDialog({
    required this.team,
    this.aktuell,
    this.onEntfernen,
    super.key,
  });

  final Team team;
  final Spieler? aktuell;
  final VoidCallback? onEntfernen;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(team.name),
      children: [
        ...team.spieler.map(
          (s) => SimpleDialogOption(
            onPressed: () => Navigator.pop(context, s),
            child: Text(
              s.name,
              style: s.id == aktuell?.id
                  ? const TextStyle(fontWeight: FontWeight.bold)
                  : null,
            ),
          ),
        ),
        if (aktuell != null && onEntfernen != null) ...[
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onEntfernen!();
            },
            child: Row(
              children: [
                Icon(
                  Icons.person_remove_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spieler:in entfernen',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
