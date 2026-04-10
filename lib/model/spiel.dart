import 'package:ue45x/model/satz.dart';
import 'package:ue45x/model/spieler.dart';

/// Ein Spiel innerhalb einer Begegnung – entweder Einzel oder Doppel.
sealed class Spiel {
  const Spiel();

  bool get istAbgeschlossen;

  int get punkteHeim;

  int get punkteGast;

  /// Alle Sätze dieses Spiels (für Torberechnung).
  List<Satz> get saetze;

  Map<String, dynamic> toJson();

  factory Spiel.fromJson(
    Map<String, dynamic> json,
    Map<String, Spieler> spielerById,
  ) {
    return switch (json['type'] as String) {
      'einzel' => Einzel.fromJson(json, spielerById,),
      'doppel' => Doppel.fromJson(json, spielerById,),
      final t => throw FormatException('Unbekannter Spiel-Typ: $t'),
    };
  }
}

/// Einzel: 1 gegen 1, ein Satz.
class Einzel extends Spiel {
  /// null = noch nicht eingetragen
  final Spieler? heimSpieler;

  /// null = noch nicht eingetragen
  final Spieler? gastSpieler;

  /// null = noch nicht gespielt
  final Satz? satz;

  const Einzel({
    this.heimSpieler,
    this.gastSpieler,
    this.satz,
  });

  @override
  bool get istAbgeschlossen => satz != null && satz!.istAbgeschlossen;

  @override
  int get punkteHeim => satz?.punkteHeim ?? 0;

  @override
  int get punkteGast => satz?.punkteGast ?? 0;

  @override
  List<Satz> get saetze => satz != null ? [satz!] : [];

  @override
  Map<String, dynamic> toJson() => {
    'type': 'einzel',
    'heim': heimSpieler?.id,
    'gast': gastSpieler?.id,
    'satz': satz?.toJson(),
  };

  factory Einzel.fromJson(
    Map<String, dynamic> json,
    Map<String, Spieler> spielerById,
  ) {
    return Einzel(
      heimSpieler: spielerById[json['heim'] as String?],
      gastSpieler: spielerById[json['gast'] as String?],
      satz: json['satz'] != null
          ? Satz.fromJson(json['satz'] as Map<String, dynamic>,)
          : null,
    );
  }
}

/// Doppel: 2 gegen 2, zwei Sätze.
class Doppel extends Spiel {
  /// Genau 2 Spieler je Seite.
  final List<Spieler> heimSpieler;
  final List<Spieler> gastSpieler;

  /// 0–2 Sätze (leer = noch nicht gespielt).
  @override
  final List<Satz> saetze;

  const Doppel({
    required this.heimSpieler,
    required this.gastSpieler,
    this.saetze = const [],
  });

  @override
  bool get istAbgeschlossen =>
      saetze.length == 2 &&
      saetze.every((s) {
        return s.istAbgeschlossen;
      });

  @override
  int get punkteHeim => saetze.fold(0, (sum, s) {
    return sum + s.punkteHeim;
  });

  @override
  int get punkteGast => saetze.fold(0, (sum, s) {
    return sum + s.punkteGast;
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': 'doppel',
    'heim': heimSpieler.map((s) {
      return s.id;
    }).toList(),
    'gast': gastSpieler.map((s) {
      return s.id;
    }).toList(),
    'saetze': saetze.map((s) {
      return s.toJson();
    }).toList(),
  };

  factory Doppel.fromJson(
    Map<String, dynamic> json,
    Map<String, Spieler> spielerById,
  ) {
    return Doppel(
      heimSpieler: (json['heim'] as List<dynamic>).map((id) {
        return spielerById[id as String]!;
      }).toList(),
      gastSpieler: (json['gast'] as List<dynamic>).map((id) {
        return spielerById[id as String]!;
      }).toList(),
      saetze: (json['saetze'] as List<dynamic>).map((s) {
        return Satz.fromJson(s as Map<String, dynamic>,);
      }).toList(),
    );
  }
}
