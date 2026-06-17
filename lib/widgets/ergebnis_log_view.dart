import 'package:flutter/material.dart';
import 'package:ue45x/services/ergebnis_log.dart';

/// Reiner Inhalt des Ergebnis-Logs: scrollbarer, kopierbarer Text
/// (neueste oben). Ohne eigene Huelle, damit er in jedem Layout sitzen kann.
class ErgebnisLogView extends StatelessWidget {
  const ErgebnisLogView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final ThemeData theme = Theme.of(context);
    return ValueListenableBuilder<List<String>>(
      valueListenable: ErgebnisLog.instance.eintraege,
      builder: (context, eintraege, child) {
        if (eintraege.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(
              24,
            ),
            child: Text(
              'Noch keine Ergebnisse eingetragen.',
            ),
          );
        }
        final List<String> umgekehrt = eintraege.reversed.toList();
        return Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              16,
            ),
            child: SelectableText(
              umgekehrt.join('\n'),
              style: theme.textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}

/// Eigenstaendiger Screen fuer das Ergebnis-Log (kein Modal).
class ErgebnisLogScreen extends StatelessWidget {
  const ErgebnisLogScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<List<String>>(
          valueListenable: ErgebnisLog.instance.eintraege,
          builder: (context, eintraege, child) {
            return Text(
              'Ergebnis-Log (${eintraege.length})',
            );
          },
        ),
      ),
      body: const ErgebnisLogView(),
    );
  }
}

/// Oeffnet das Ergebnis-Log als eigene Seite.
Future<void> oeffneErgebnisLog(
  BuildContext context,
) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) {
        return const ErgebnisLogScreen();
      },
    ),
  );
}
