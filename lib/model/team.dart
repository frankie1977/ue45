import 'package:ue45x/model/spieler.dart';

class Team {
  final String id;
  final String name;
  final List<Spieler> spieler;

  const Team({required this.id, required this.name, required this.spieler});

  /// 5–10 Spieler erlaubt.
  bool get istGueltig => spieler.length >= 5 && spieler.length <= 10;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'spieler': spieler.map((s) {
      return s.toJson();
    }).toList(),
  };

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      spieler: (json['spieler'] as List<dynamic>).map((s) {
        return Spieler.fromJson(s as Map<String, dynamic>);
      }).toList(),
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) => other is Team && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
