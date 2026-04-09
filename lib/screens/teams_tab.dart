import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';
import 'package:ue45x/widgets/namen_dialog.dart';
import 'package:ue45x/widgets/spieler_dialog.dart';
import 'package:ue45x/widgets/team_card.dart';

class TeamsTab extends StatelessWidget {
  const TeamsTab({
    required this.liga,
    required this.onLigaGeaendert,
    super.key,
  });

  final Liga liga;
  final void Function(Liga) onLigaGeaendert;

  Future<void> _teamUmbenennen(BuildContext context, Team team) async {
    final neuerName = await showDialog<String>(
      context: context,
      builder: (ctx) => NamenDialog(
        titel: 'Team umbenennen',
        initialText: team.name,
        bestaetigenText: 'Umbenennen',
      ),
    );
    if (neuerName != null && neuerName.isNotEmpty) {
      onLigaGeaendert(liga.mitTeamUmbenennt(team.id, neuerName));
    }
  }

  Future<void> _teamHinzufuegen(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => NamenDialog(
        titel: 'Team hinzufügen',
        initialText: '',
        bestaetigenText: 'Hinzufügen',
      ),
    );
    if (name != null && name.isNotEmpty) {
      final id = 't${DateTime.now().millisecondsSinceEpoch}';
      onLigaGeaendert(
        liga.mitTeamHinzugefuegt(Team(id: id, name: name, spieler: [])),
      );
    }
  }

  Future<void> _teamLoeschen(BuildContext context, Team team) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Team löschen'),
        content: Text('${team.name} wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onLigaGeaendert(liga.mitTeamEntfernt(team.id));
    }
  }

  Future<void> _spielerUmbenennen(
    BuildContext context,
    Team team,
    Spieler spieler,
  ) async {
    final result = await showDialog<({String vorname, String nachname})>(
      context: context,
      builder: (ctx) => SpielerDialog(
        titel: 'Spieler:in umbenennen',
        initialVorname: spieler.vorname,
        initialNachname: spieler.nachname,
        bestaetigenText: 'Umbenennen',
      ),
    );
    if (result != null) {
      onLigaGeaendert(
        liga.mitSpielerUmbenennt(
          team.id,
          Spieler(
            id: spieler.id,
            vorname: result.vorname,
            nachname: result.nachname,
          ),
        ),
      );
    }
  }

  Future<void> _spielerLoeschen(
    BuildContext context,
    Team team,
    Spieler spieler,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Spieler:in entfernen'),
        content: Text('${spieler.name} aus ${team.name} entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onLigaGeaendert(liga.mitSpielerEntfernt(team.id, spieler.id));
    }
  }

  Future<void> _spielerHinzufuegen(BuildContext context, Team team) async {
    final result = await showDialog<({String vorname, String nachname})>(
      context: context,
      builder: (ctx) => SpielerDialog(
        titel: 'Spieler:in hinzufügen',
        initialVorname: '',
        initialNachname: '',
        bestaetigenText: 'Hinzufügen',
      ),
    );
    if (result != null) {
      final id = '${team.id}_s${DateTime.now().millisecondsSinceEpoch}';
      onLigaGeaendert(
        liga.mitSpielerHinzugefuegt(
          team.id,
          Spieler(id: id, vorname: result.vorname, nachname: result.nachname),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kannLoeschen = !liga.hatErgebnisse;
    final aufgestellt = liga.aufgestellteSpielerIds;
    return Scaffold(
      body: ListView.builder(
        itemCount: liga.teams.length,
        itemBuilder: (context, index) {
          final team = liga.teams[index];
          return TeamCard(
            team: team,
            kannLoeschen: kannLoeschen,
            aufgestellteSpielerIds: aufgestellt,
            onUmbenennen: () => _teamUmbenennen(context, team),
            onLoeschen: () => _teamLoeschen(context, team),
            onSpielerUmbenennen: (s) => _spielerUmbenennen(context, team, s),
            onSpielerLoeschen: (s) => _spielerLoeschen(context, team, s),
            onSpielerHinzufuegen: () => _spielerHinzufuegen(context, team),
          );
        },
      ),
      floatingActionButton: kannLoeschen
          ? FloatingActionButton(
              onPressed: () => _teamHinzufuegen(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
