import 'package:flutter/material.dart';

class SpielerDialog extends StatefulWidget {
  const SpielerDialog({
    required this.titel,
    required this.initialVorname,
    required this.initialNachname,
    required this.bestaetigenText,
    super.key,
  });

  final String titel;
  final String initialVorname;
  final String initialNachname;
  final String bestaetigenText;

  @override
  State<SpielerDialog> createState() => _SpielerDialogState();
}

class _SpielerDialogState extends State<SpielerDialog> {
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
        mainAxisSize: .min,
        children: [
          TextField(
            controller: _vornameCtrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Vorname'),
            textCapitalization: .words,
            onSubmitted: (_) {
              _nachnameFocus.requestFocus();
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nachnameCtrl,
            focusNode: _nachnameFocus,
            decoration: const InputDecoration(labelText: 'Nachname'),
            textCapitalization: .words,
            onSubmitted: (_) {
              _bestaetigen();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
