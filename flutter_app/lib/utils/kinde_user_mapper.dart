import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';

import '../models/auth_user.dart';

AuthUser authUserFromKinde(UserProfileV2 profile) {
  final first = profile.firstName?.trim() ?? '';
  final last = profile.lastName?.trim() ?? '';
  final combined = '$first $last'.trim();
  final email = profile.preferredEmail?.trim() ?? '';

  return AuthUser(
    id: profile.id ?? email,
    email: email,
    name: combined.isNotEmpty
        ? combined
        : (email.contains('@') ? email.split('@').first : 'Player'),
    avatarURL: profile.picture,
  );
}
