class User {
  int? id;
  String email;
  String passwordHash;
  String role; // 'teacher', 'cdd', 'director'
  String? displayName;
  String? createdAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.displayName,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'role': role,
      'display_name': displayName,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      role: map['role'],
      displayName: map['display_name'],
      createdAt: map['created_at'],
    );
  }
}
