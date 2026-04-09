class Tisch {
  const Tisch({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };

  factory Tisch.fromJson(Map<String, dynamic> json) => Tisch(
    id: json['id'] as String,
    name: json['name'] as String,
  );
}
