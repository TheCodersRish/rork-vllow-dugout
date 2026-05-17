class AuthUser {
  final String email;
  final String name;
  final String? avatarURL;

  AuthUser({
    required this.email,
    required this.name,
    this.avatarURL,
  });
}
