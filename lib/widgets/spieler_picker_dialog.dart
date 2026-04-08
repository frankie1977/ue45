import 'package:flutter/material.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';

class SpielerPickerDialog extends StatelessWidget {
  const SpielerPickerDialog({
    required this.team,
    this.aktuell,
    super.key,
  });

  final Team team;
  final Spieler? aktuell;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(team.name),
      children: team.spieler
          .map(
            (s) => SimpleDialogOption(
              onPressed: () => Navigator.pop(context, s),
              child: Text(
                s.name,
                style: s.id == aktuell?.id
                    ? const TextStyle(fontWeight: FontWeight.bold)
                    : null,
              ),
            ),
          )
          .toList(),
    );
  }
}
