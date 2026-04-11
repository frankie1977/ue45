import 'package:flutter/material.dart';
import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/liga.dart';
import 'package:ue45x/model/spieltag.dart';
import 'package:ue45x/model/tisch.dart';
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

    final List<Tisch> tische = widget.liga.tische;

    final List<Widget> hinrundeWidgets = [];
    int hinIndex = 0;
    for (final Spieltag st in widget.liga.hinrunde) {
      hinrundeWidgets.add(
        SpieltagSection(
          spieltag: st,
          startIndex: hinIndex,
          tische: tische,
          onBegegnungGeaendert: widget.onBegegnungGeaendert,
          istAktiv: st == aktiverSpieltag,
        ),
      );
      hinIndex += st.begegnungen.length;
    }

    final List<Widget> rueckrundeWidgets = [];
    int rueckIndex = 0;
    for (final Spieltag st in widget.liga.rueckrunde) {
      rueckrundeWidgets.add(
        SpieltagSection(
          spieltag: st,
          startIndex: rueckIndex,
          tische: tische,
          onBegegnungGeaendert: widget.onBegegnungGeaendert,
          istAktiv: st == aktiverSpieltag,
        ),
      );
      rueckIndex += st.begegnungen.length;
    }

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
