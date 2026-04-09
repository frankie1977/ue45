import 'package:flutter/material.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    required this.team,
    required this.kannLoeschen,
    required this.aufgestellteSpielerIds,
    required this.onUmbenennen,
    required this.onLoeschen,
    required this.onSpielerUmbenennen,
    required this.onSpielerLoeschen,
    required this.onSpielerHinzufuegen,
    super.key,
  });

  final Team team;
  final bool kannLoeschen;
  final Set<String> aufgestellteSpielerIds;
  final VoidCallback onUmbenennen;
  final VoidCallback onLoeschen;
  final void Function(Spieler) onSpielerUmbenennen;
  final void Function(Spieler) onSpielerLoeschen;
  final VoidCallback onSpielerHinzufuegen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const .symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ExpansionTile(
        leading: const Icon(Icons.groups),
        title: Text(
          team.name,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text('${team.spieler.length} Spieler:innen'),
        trailing: Row(
          mainAxisSize: .min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onUmbenennen,
              tooltip: 'Umbenennen',
            ),
            if (kannLoeschen)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
                onPressed: onLoeschen,
                tooltip: 'Team löschen',
              ),
          ],
        ),
        children: [
          ...team.spieler.map(
            (s) {
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  s.name,
                  style: theme.textTheme.bodyLarge,
                ),
                trailing: Row(
                  mainAxisSize: .min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        onSpielerUmbenennen(s);
                      },
                      tooltip: 'Umbenennen',
                    ),
                    if (kannLoeschen && !aufgestellteSpielerIds.contains(s.id))
                      IconButton(
                        icon: const Icon(Icons.person_remove_outlined),
                        color: theme.colorScheme.error,
                        onPressed: () {
                          onSpielerLoeschen(s);
                        },
                        tooltip: 'Entfernen',
                      ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add_outlined),
            title: const Text('Spieler:in hinzufügen'),
            onTap: onSpielerHinzufuegen,
          ),
        ],
      ),
    );
  }
}
