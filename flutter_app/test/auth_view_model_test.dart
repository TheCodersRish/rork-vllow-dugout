import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vllow_dugout/providers/auth_view_model.dart';

void main() {
  test('mock mode restores and clears the persisted user session', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = AuthViewModel(prefs);
    await auth.init();

    await auth.signIn('rishan@example.com', 'password');

    expect(auth.isAuthenticated, isTrue);
    expect(auth.currentUser?.email, 'rishan@example.com');

    final restored = AuthViewModel(prefs);
    await restored.init();
    expect(restored.currentUser?.email, 'rishan@example.com');

    await restored.signOut();
    final cleared = AuthViewModel(prefs);
    await cleared.init();
    expect(cleared.isAuthenticated, isFalse);
  });
}
