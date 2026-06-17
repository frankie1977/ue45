/// Ein Satz: bis max 6 Tore.
/// 6:x (x < 6) → Sieg (2:0 Punkte), 5:5 → Unentschieden (1:1 Punkte).
class Satz {
  final int heimTore;
  final int gastTore;

  const Satz({
    required this.heimTore,
    required this.gastTore,
  });

  bool get istGueltig =>
      (heimTore == 5 && gastTore == 5) ||
      (heimTore == 6 && gastTore < 5 && gastTore >= 0) ||
      (gastTore == 6 && heimTore < 5 && heimTore >= 0);

  bool get istUnentschieden => heimTore == 5 && gastTore == 5;

  bool get heimGewinnt => heimTore == 6 && gastTore < 6;

  bool get gastGewinnt => gastTore == 6 && heimTore < 6;

  bool get istAbgeschlossen => heimGewinnt || gastGewinnt || istUnentschieden;

  int get punkteHeim {
    if (istUnentschieden) {
      return 1;
    }
    if (heimGewinnt) {
      return 2;
    }
    return 0;
  }

  int get punkteGast {
    if (istUnentschieden) {
      return 1;
    }
    if (gastGewinnt) {
      return 2;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
    'heim': heimTore,
    'gast': gastTore,
  };

  factory Satz.fromJson(Map<String, dynamic> json) => Satz(
    heimTore: json['heim'] as int,
    gastTore: json['gast'] as int,
  );

  @override
  String toString() => '$heimTore:$gastTore';
}
