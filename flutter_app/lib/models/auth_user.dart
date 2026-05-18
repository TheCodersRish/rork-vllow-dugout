class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? avatarURL;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarURL,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? json['email'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarURL: json['avatarURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarURL': avatarURL,
    };
  }
}
