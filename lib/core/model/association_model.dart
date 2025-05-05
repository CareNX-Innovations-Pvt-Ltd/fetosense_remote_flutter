class Association {
  final String id;
  final String name;
  final String type;

  /// Constructs an [Association] instance.
  ///
  /// [id] is the unique identifier of the association.
  /// [name] is the name of the association.
  /// [type] is the type of the association.
  Association({
    required this.id,
    required this.name,
    required this.type,
  });

  /// Constructs an [Association] instance from a map.
  ///
  /// [snapshot] is a map containing the association data.
  factory Association.fromMap(Map snapshot) {
    return Association(
      id: snapshot['id'] ?? '',
      name: snapshot['name'] ?? '',
      type: snapshot['type'] ?? '',
    );
  }

  /// Converts the [Association] instance to a map.
  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }
}
