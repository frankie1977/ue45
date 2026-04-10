import 'package:ue45x/model/begegnung.dart';
import 'package:ue45x/model/spieler.dart';
import 'package:ue45x/model/team.dart';
import 'package:ue45x/model/tisch.dart';

/// Ein Spieltag enthält alle Begegnungen einer Runde.
/// Bei ungerader Teamanzahl hat ein Team ein Freilos.
class Spieltag {
  final int nummer;
  final List<Begegnung> begegnungen;

  /// Null wenn gerade Teamanzahl, sonst das Team mit Freilos.
  final Team? freilos;
  final bool istHinrunde;

  const Spieltag({
    required this.nummer,
    required this.begegnungen,
    required this.istHinrunde,
    this.freilos,
  });

  /// Gibt einen neuen [Spieltag] zurück, bei dem [begegnung] ersetzt ist.
  Spieltag mitBegegnung(Begegnung begegnung) {
    if (!begegnungen.any((b) {
      return b.id == begegnung.id;
    })) {
      return this;
    }
    return Spieltag(
      nummer: nummer,
      istHinrunde: istHinrunde,
      freilos: freilos,
      begegnungen: [
        for (final b in begegnungen)
          if (b.id == begegnung.id) begegnung else b,
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'nummer': nummer,
    'hin': istHinrunde,
    'frei': freilos?.id,
    'begegnungen': begegnungen.map((b) {
      return b.toJson();
    }).toList(),
  };

  factory Spieltag.fromJson(
    Map<String, dynamic> json,
    Map<String, Team> teamsById,
    Map<String, Tisch> tischeById,
    Map<String, Spieler> spielerById,
  ) {
    final freilosId = json['frei'] as String?;
    return Spieltag(
      nummer: json['nummer'] as int,
      istHinrunde: json['hin'] as bool,
      freilos: freilosId != null ? teamsById[freilosId] : null,
      begegnungen: (json['begegnungen'] as List<dynamic>).map((b) {
        return Begegnung.fromJson(
          b as Map<String, dynamic>,
          teamsById,
          tischeById,
          spielerById,
        );
      }).toList(),
    );
  }
}
