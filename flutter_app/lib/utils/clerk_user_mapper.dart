import 'package:clerk_auth/clerk_auth.dart' as clerk;

import '../models/auth_user.dart';

AuthUser authUserFromClerk(clerk.User user) {
  final email = user.email ?? user.primaryEmailAddress?.emailAddress ?? '';
  final name = [
    user.firstName,
    user.lastName,
  ].where((part) => part != null && part!.trim().isNotEmpty).join(' ').trim();

  return AuthUser(
    id: user.id,
    email: email,
    name: name.isEmpty ? (email.contains('@') ? email.split('@').first : 'Champion') : name,
    avatarURL: user.profileImageUrl,
  );
}
