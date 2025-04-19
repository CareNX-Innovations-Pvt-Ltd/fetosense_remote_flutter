/// A model class representing an association.
class Association {
  String? id;
  String? name;
  String? type;

  /// Constructs an [Association] instance.
  ///
  /// [id] is the unique identifier of the association.
  /// [name] is the name of the association.
  /// [type] is the type of the association.
  Association({this.id, this.name, this.type});

  /// Constructs an [Association] instance from a map.
  ///
  /// [snapshot] is a map containing the association data.
  Association.fromMap(Map snapshot)
      : id = snapshot['id'] ?? '',
        name = snapshot['name'] ?? '',
        type = snapshot['type'] ?? '';

  /// Gets the ID of the association.
  ///
  /// Returns the ID as a [String].
  String? getId() {
    return id;
  }

  /// Sets the ID of the association.
  ///
  /// [id] is the new ID to be set.
  void setId(String id) {
    this.id = id;
  }

  /// Gets the name of the association.
  ///
  /// Returns the name as a [String].
  String? getName() {
    return name;
  }

  /// Sets the name of the association.
  ///
  /// [name] is the new name to be set.
  void setName(String name) {
    this.name = name;
  }

  /// Gets the type of the association.
  ///
  /// Returns the type as a [String].
  String? getType() {
    return type;
  }

  /// Sets the type of the association.
  ///
  /// [type] is the new type to be set.
  void setType(String type) {
    this.type = type;
  }
}

// class Association{
//
//   String? id;
//   String? name;
//   String? type;
//
//   Association({this.id,
//              this.name,
//               this.type});
// /*  Association(User user) {
//     this.id = user.getDocumentId();
//     this.name = user.getName();
//     this.type = user.getType();
//   }*/
//
//
//   Association.fromMap(Map snapshot):
//         id = snapshot['id']  ?? '',
//         name = snapshot['name'] ?? '',
//         type = snapshot['type'] ?? '';
//
//   String? getId() {
//     return id;
//   }
//
//   void setId(String id) {
//     this.id = id;
//   }
//
//   String? getName() {
//     return name;
//   }
//
//   void setName(String name) {
//     this.name = name;
//   }
//
//   String? getType() {
//     return type;
//   }
//
//   void setType(String type) {
//     this.type = type;
//   }
//
// }
