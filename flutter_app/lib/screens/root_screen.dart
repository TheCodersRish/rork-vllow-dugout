import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_view_model.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'auth_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        switch (auth.authState) {
          case AuthFlowState.onboarding:
            return const OnboardingScreen();
          case AuthFlowState.auth:
            return const AuthScreen();
          case AuthFlowState.main:
            return const MainScreen();
        }
      },
    );
  }
}
