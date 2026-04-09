import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/widgets/begegnungen/runde_header.dart';
import 'package:ue45x/widgets/begegnungen/spieltag_section.dart';

class BegegnungenTab extends StatefulWidget {
  const BegegnungenTab({
    required this.liga,
    required this.onBegegnungGeaendert,
    super.key,
  });

  final Liga liga;
  final void Function(Begegnung) onBegegnungGeaendert;

  @override
  State<BegegnungenTab> createState() => _BegegnungenTabState();
}

class _BegegnungenTabState extends State<BegegnungenTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final alleSpieltage = [
      ...widget.liga.hinrunde,
      ...widget.liga.rueckrunde,
    ];
    final aktiverSpieltag = alleSpieltage
        .where(
          (st) => !st.begegnungen.every((b) => b.istAbgeschlossen),
        )
        .firstOrNull;

    final tische = widget.liga.tische;
    int index = 0;
    final hinrundeWidgets = widget.liga.hinrunde.map((st) {
      final w = SpieltagSection(
        spieltag: st,
        startIndex: index,
        tische: tische,
        onBegegnungGeaendert: widget.onBegegnungGeaendert,
        istAktiv: st == aktiverSpieltag,
      );
      index += st.begegnungen.length;
      return w;
    }).toList();
    index = 0;
    final rueckrundeWidgets = widget.liga.rueckrunde.map((st) {
      final w = SpieltagSection(
        spieltag: st,
        startIndex: index,
        tische: tische,
        onBegegnungGeaendert: widget.onBegegnungGeaendert,
        istAktiv: st == aktiverSpieltag,
      );
      index += st.begegnungen.length;
      return w;
    }).toList();

    return ListView(
      children: [
        const RundeHeader(titel: 'Hinrunde'),
        ...hinrundeWidgets,
        const RundeHeader(titel: 'Rückrunde'),
        ...rueckrundeWidgets,
      ],
    );
  }
}
