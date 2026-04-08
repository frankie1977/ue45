import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';

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
      builder: (ctx) => _NamenDialog(
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
      builder: (ctx) => _NamenDialog(
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
      builder: (ctx) => _SpielerDialog(
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
      builder: (ctx) => _SpielerDialog(
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
    return Scaffold(
      body: ListView.builder(
        itemCount: liga.teams.length,
        itemBuilder: (context, index) {
          final team = liga.teams[index];
          return _TeamCard(
            team: team,
            kannLoeschen: kannLoeschen,
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

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.team,
    required this.kannLoeschen,
    required this.onUmbenennen,
    required this.onLoeschen,
    required this.onSpielerUmbenennen,
    required this.onSpielerLoeschen,
    required this.onSpielerHinzufuegen,
  });

  final Team team;
  final bool kannLoeschen;
  final VoidCallback onUmbenennen;
  final VoidCallback onLoeschen;
  final void Function(Spieler) onSpielerUmbenennen;
  final void Function(Spieler) onSpielerLoeschen;
  final VoidCallback onSpielerHinzufuegen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(
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
          mainAxisSize: MainAxisSize.min,
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
            (s) => ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(
                s.name,
                style: theme.textTheme.bodyLarge,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => onSpielerUmbenennen(s),
                    tooltip: 'Umbenennen',
                  ),
                  if (kannLoeschen)
                    IconButton(
                      icon: const Icon(Icons.person_remove_outlined),
                      color: theme.colorScheme.error,
                      onPressed: () => onSpielerLoeschen(s),
                      tooltip: 'Entfernen',
                    ),
                ],
              ),
            ),
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

class _NamenDialog extends StatefulWidget {
  const _NamenDialog({
    required this.titel,
    required this.initialText,
    required this.bestaetigenText,
  });

  final String titel;
  final String initialText;
  final String bestaetigenText;

  @override
  State<_NamenDialog> createState() => _NamenDialogState();
}

class _NamenDialogState extends State<_NamenDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bestaetigen() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titel),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Teamname'),
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _bestaetigen(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _bestaetigen,
          child: Text(widget.bestaetigenText),
        ),
      ],
    );
  }
}

class _SpielerDialog extends StatefulWidget {
  const _SpielerDialog({
    required this.titel,
    required this.initialVorname,
    required this.initialNachname,
    required this.bestaetigenText,
  });

  final String titel;
  final String initialVorname;
  final String initialNachname;
  final String bestaetigenText;

  @override
  State<_SpielerDialog> createState() => _SpielerDialogState();
}

class _SpielerDialogState extends State<_SpielerDialog> {
  late final TextEditingController _vornameCtrl;
  late final TextEditingController _nachnameCtrl;
  final FocusNode _nachnameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _vornameCtrl = TextEditingController(text: widget.initialVorname);
    _nachnameCtrl = TextEditingController(text: widget.initialNachname);
  }

  @override
  void dispose() {
    _vornameCtrl.dispose();
    _nachnameCtrl.dispose();
    _nachnameFocus.dispose();
    super.dispose();
  }

  void _bestaetigen() {
    final vorname = _vornameCtrl.text.trim();
    final nachname = _nachnameCtrl.text.trim();
    if (vorname.isNotEmpty && nachname.isNotEmpty) {
      Navigator.pop(context, (vorname: vorname, nachname: nachname));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _vornameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Vorname'),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _nachnameFocus.requestFocus(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nachnameCtrl,
            focusNode: _nachnameFocus,
            decoration: const InputDecoration(labelText: 'Nachname'),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _bestaetigen(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _bestaetigen,
          child: Text(widget.bestaetigenText),
        ),
      ],
    );
  }
}
