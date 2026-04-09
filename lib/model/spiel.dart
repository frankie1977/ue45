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

  factory Spiel.fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'einzel' => Einzel.fromJson(json),
      'doppel' => Doppel.fromJson(json),
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
    'heimSpieler': heimSpieler?.toJson(),
    'gastSpieler': gastSpieler?.toJson(),
    'satz': satz?.toJson(),
  };

  factory Einzel.fromJson(Map<String, dynamic> json) {
    return Einzel(
      heimSpieler: json['heimSpieler'] != null
          ? Spieler.fromJson(json['heimSpieler'] as Map<String, dynamic>)
          : null,
      gastSpieler: json['gastSpieler'] != null
          ? Spieler.fromJson(json['gastSpieler'] as Map<String, dynamic>)
          : null,
      satz: json['satz'] != null
          ? Satz.fromJson(json['satz'] as Map<String, dynamic>)
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
    'heimSpieler': heimSpieler.map((s) {
      return s.toJson();
    }).toList(),
    'gastSpieler': gastSpieler.map((s) {
      return s.toJson();
    }).toList(),
    'saetze': saetze.map((s) {
      return s.toJson();
    }).toList(),
  };

  factory Doppel.fromJson(Map<String, dynamic> json) {
    return Doppel(
      heimSpieler: (json['heimSpieler'] as List<dynamic>).map((s) {
        return Spieler.fromJson(s as Map<String, dynamic>);
      }).toList(),
      gastSpieler: (json['gastSpieler'] as List<dynamic>).map((s) {
        return Spieler.fromJson(s as Map<String, dynamic>);
      }).toList(),
      saetze: (json['saetze'] as List<dynamic>).map((s) {
        return Satz.fromJson(s as Map<String, dynamic>);
      }).toList(),
    );
  }
}
