class AuthUser {
  final String email;
  final String name;
  final String? avatarURL;

  AuthUser({
    required this.email,
    required this.name,
    this.avatarURL,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      email: json['email'] as String,
      name: json['name'] as String,
      avatarURL: json['avatarURL'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'avatarURL': avatarURL,
    };
  }
}
