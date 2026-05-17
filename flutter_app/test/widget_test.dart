import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vllow_dugout/main.dart';
import 'package:vllow_dugout/providers/app_state.dart';
import 'package:vllow_dugout/providers/auth_view_model.dart';
import 'package:vllow_dugout/providers/coach_view_model.dart';
import 'package:vllow_dugout/providers/local_modules_view_model.dart';
import 'package:vllow_dugout/providers/meal_plan_view_model.dart';
import 'package:vllow_dugout/providers/player_profile_view_model.dart';

void main() {
  testWidgets('Vllow Dugout boots to onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final appState = AppState();
    await appState.init(prefs);
    final authViewModel = AuthViewModel(prefs);
    await authViewModel.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: authViewModel),
          ChangeNotifierProvider(
            create: (_) => CoachViewModel(prefs)..configure(appState),
          ),
          ChangeNotifierProvider(create: (_) => LocalModulesViewModel(prefs)),
          ChangeNotifierProvider(create: (_) => MealPlanViewModel(prefs)),
          ChangeNotifierProvider(create: (_) => PlayerProfileViewModel(prefs)),
        ],
        child: const VllowDugoutApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Train Like'), findsOneWidget);
    expect(find.textContaining('The Elite'), findsOneWidget);
  });
}
