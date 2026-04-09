import 'package:flutter/material.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/tisch.dart';
import 'package:ue45x/widgets/anmeldung/namen_dialog.dart';

class TischeTab extends StatelessWidget {
  const TischeTab({
    required this.liga,
    required this.onLigaGeaendert,
    super.key,
  });

  final Liga liga;
  final void Function(Liga) onLigaGeaendert;

  Future<void> _tischHinzufuegen(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return NamenDialog(
          titel: 'Tisch hinzufügen',
          initialText: 'Tisch ${liga.tische.length + 1}',
          bestaetigenText: 'Hinzufügen',
        );
      },
    );
    if (name != null && name.isNotEmpty) {
      final id = 'tisch_${DateTime.now().millisecondsSinceEpoch}';
      onLigaGeaendert(
        liga.mitTischHinzugefuegt(
          Tisch(id: id, name: name,),
        ),
      );
    }
  }

  Future<void> _tischUmbenennen(BuildContext context, Tisch tisch) async {
    final neuerName = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return NamenDialog(
          titel: 'Tisch umbenennen',
          initialText: tisch.name,
          bestaetigenText: 'Umbenennen',
        );
      },
    );
    if (neuerName != null && neuerName.isNotEmpty) {
      onLigaGeaendert(liga.mitTischUmbenennt(tisch.id, neuerName,));
    }
  }

  Future<void> _tischEntfernen(BuildContext context, Tisch tisch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tisch entfernen'),
          content: Text('${tisch.name} wirklich entfernen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('Entfernen'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      onLigaGeaendert(liga.mitTischEntfernt(tisch.id,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: liga.tische.isEmpty
          ? const Center(
              child: Text('Noch keine Tische angelegt.'),
            )
          : ListView.builder(
              itemCount: liga.tische.length,
              itemBuilder: (context, index) {
                final tisch = liga.tische[index];
                return ListTile(
                  leading: const Icon(Icons.table_restaurant),
                  title: Text(tisch.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Umbenennen',
                        onPressed: () {
                          _tischUmbenennen(context, tisch);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Entfernen',
                        onPressed: () {
                          _tischEntfernen(context, tisch);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tischHinzufuegen(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
