import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vllow_dugout/services/auth_service.dart';

void main() {
  test('mock mode restores and clears the persisted user session', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final authService = AuthService(
      prefs,
      useFirebase: false,
    );

    final user = await authService.signIn(
      email: 'rishan@example.com',
      password: 'password',
    );

    expect(user.email, 'rishan@example.com');
    expect(user.id, isNotEmpty);

    final restoredService = AuthService(prefs, useFirebase: false);
    final restoredUser = await restoredService.getCurrentUser();
    expect(restoredUser?.email, 'rishan@example.com');

    await restoredService.signOut();
    expect(await AuthService(prefs, useFirebase: false).getCurrentUser(), isNull);
  });
}
