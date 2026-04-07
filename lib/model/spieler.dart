class Spieler {
  final String id;
  final String vorname;
  final String nachname;

  const Spieler({
    required this.id,
    required this.vorname,
    required this.nachname,
  });

  String get name => '$vorname $nachname';

  Map<String, dynamic> toJson() => {
    'id': id,
    'vorname': vorname,
    'nachname': nachname,
  };

  factory Spieler.fromJson(Map<String, dynamic> json) => Spieler(
    id: json['id'] as String,
    vorname: json['vorname'] as String,
    nachname: json['nachname'] as String,
  );

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) => other is Spieler && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
