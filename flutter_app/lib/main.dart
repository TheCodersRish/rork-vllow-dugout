import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_state.dart';
import 'providers/auth_view_model.dart';
import 'providers/coach_view_model.dart';
import 'providers/local_modules_view_model.dart';
import 'providers/meal_plan_view_model.dart';
import 'providers/player_profile_view_model.dart';
import 'utils/app_theme.dart';
import 'screens/root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final appState = AppState();
  await appState.init(prefs);

  final authViewModel = AuthViewModel(prefs);
  await authViewModel.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: authViewModel),
        ChangeNotifierProvider(
            create: (_) => CoachViewModel(prefs)..configure(appState)),
        ChangeNotifierProvider(create: (_) => LocalModulesViewModel(prefs)),
        ChangeNotifierProvider(create: (_) => MealPlanViewModel(prefs)),
        ChangeNotifierProvider(create: (_) => PlayerProfileViewModel(prefs)),
      ],
      child: const VllowDugoutApp(),
    ),
  );
}

class VllowDugoutApp extends StatelessWidget {
  const VllowDugoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vllow Dugout',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const RootScreen(),
    );
  }
}
