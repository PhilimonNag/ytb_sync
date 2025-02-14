class User {
  final String id;
  final String? name;

  User({required this.id, this.name});

  User copyWith({
    String? id,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
