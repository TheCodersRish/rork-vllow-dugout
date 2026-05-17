import 'package:flutter/material.dart';
import 'app_state.dart';

class CoachViewModel extends ChangeNotifier {
  AppState? _appState;

  void configure(AppState appState) {
    _appState = appState;
  }

  AppState? get appState => _appState;
}
