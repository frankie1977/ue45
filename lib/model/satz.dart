/// Ein Satz: bis max 7 Tore.
/// 7:x (x < 7) → Sieg (2:0 Punkte), 6:6 → Unentschieden (1:1 Punkte).
class Satz {
  final int heimTore;
  final int gastTore;

  const Satz({required this.heimTore, required this.gastTore});

  bool get istGueltig =>
      (heimTore == 6 && gastTore == 6) ||
      (heimTore == 7 && gastTore < 6 && gastTore >= 0) ||
      (gastTore == 7 && heimTore < 6 && heimTore >= 0);

  bool get istUnentschieden => heimTore == 6 && gastTore == 6;

  bool get heimGewinnt => heimTore == 7 && gastTore < 7;

  bool get gastGewinnt => gastTore == 7 && heimTore < 7;

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

  Map<String, dynamic> toJson() => {'heimTore': heimTore, 'gastTore': gastTore};

  factory Satz.fromJson(Map<String, dynamic> json) => Satz(
    heimTore: json['heimTore'] as int,
    gastTore: json['gastTore'] as int,
  );

  @override
  String toString() => '$heimTore:$gastTore';
}
