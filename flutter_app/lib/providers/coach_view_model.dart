import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import 'app_state.dart';

class CoachViewModel extends ChangeNotifier {
  static const _messagesKey = 'coach_chat_messages';
  static const _welcomeMessage =
      "Welcome to your personal AI coaching session! I'm FR-03, your elite cricket coach. I can help with batting technique, bowling drills, fielding, fitness plans, mental game, and match strategy.\n\nWhat would you like to work on today?";

  final SharedPreferences _prefs;
  AppState? _appState;
  late List<ChatMessage> _messages;

  CoachViewModel(this._prefs) {
    _messages = _loadMessages();
  }

  void configure(AppState appState) {
    _appState = appState;
  }

  AppState? get appState => _appState;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  int get sessionCount =>
      _messages.where((message) => message.role == MessageRole.user).length + 1;

  void addUserMessage(String content) {
    _messages.add(ChatMessage(role: MessageRole.user, content: content));
    _persist();
    notifyListeners();
  }

  void addAssistantMessage(ChatMessage message) {
    _messages.add(message);
    _persist();
    notifyListeners();
  }

  void clearHistory() {
    _messages = [_defaultWelcomeMessage()];
    _persist();
    notifyListeners();
  }

  List<ChatMessage> _loadMessages() {
    final json = _prefs.getString(_messagesKey);
    if (json == null) return [_defaultWelcomeMessage()];

    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      final messages = decoded
          .map((item) =>
              ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      return messages.isEmpty ? [_defaultWelcomeMessage()] : messages;
    } catch (_) {
      _prefs.remove(_messagesKey);
      return [_defaultWelcomeMessage()];
    }
  }

  ChatMessage _defaultWelcomeMessage() {
    return ChatMessage(
      role: MessageRole.assistant,
      content: _welcomeMessage,
    );
  }

  void _persist() {
    _prefs.setString(
      _messagesKey,
      jsonEncode(_messages.map((message) => message.toJson()).toList()),
    );
  }
}
