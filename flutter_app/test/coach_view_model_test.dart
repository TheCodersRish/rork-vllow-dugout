import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vllow_dugout/models/chat_message.dart';
import 'package:vllow_dugout/providers/coach_view_model.dart';

void main() {
  test('persists and resets AI coach chat history', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final coach = CoachViewModel(prefs);

    expect(coach.messages, hasLength(1));

    coach.addUserMessage('How do I improve my cover drive?');
    coach.addAssistantMessage(
      ChatMessage(
        role: MessageRole.assistant,
        content: 'Keep your head still and play under your eyes.',
        drillAttachment: DrillAttachment(
          title: 'Cover Drive Masterclass',
          subtitle: 'BATTING',
          imageURL: 'https://example.com/drill.jpg',
          duration: '12M',
        ),
      ),
    );

    final restored = CoachViewModel(prefs);
    expect(restored.messages, hasLength(3));
    expect(restored.messages[1].content, 'How do I improve my cover drive?');
    expect(
        restored.messages[2].drillAttachment?.title, 'Cover Drive Masterclass');

    restored.clearHistory();
    expect(CoachViewModel(prefs).messages, hasLength(1));
  });
}
